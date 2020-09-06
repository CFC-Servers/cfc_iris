# frozen_string_literal: true

require 'http'

DISCORD_API = 'https://discord.com/api/v6'
CFC_BOT_TOKEN = Rails.application.credentials.cfc_bot_token
CLIENT_ID = '650800239157968896'
CLIENT_SECRET = Rails.application.credentials.client_secret
DISCORD_REDIRECT_URL = 'https://iris.cfcservers.org/api/callbacks/discord'

URL_BASE = 'https://cfcservers.org/link'
SUCCESS_URL = "#{URL_BASE}/success"
FAILURE_URL = "#{URL_BASE}/failure"

class CallbacksController < ApplicationController
  before_action :validate_discord_callback, only: [:receive_discord_callback]

  def receive_discord_callback
    token = get_token_from_code(params['code'])
    discord_info = get_discord_info(token)
    discord_id = discord_info['id']

    error_codes = []
    identity_rows = []

    user_connections = get_user_connections(token)

    # Array of hashes to be used in a where chain
    connection_pairs = user_connections.map do |c|
      { identifier: c['id'], platform: c['type'] }
    end

    # Generate a query to find any Identity with the
    # specific pairs of identifiers and platforms
    # TODO: Extract to model?
    found_identities = connection_pairs.inject(Identity.none) do |memo, pair|
      memo.or(Identity.where(pair))
    end.pluck(:identifier, :user_id).to_h

    ## TODO: DRY these two conditions
    if connection_pairs.select { |c| c[:platform] == 'steam' }.empty?
      error_codes << 'discord-missing-steam'
    end

    if connection_pairs.select { |c| c[:platform] == 'discord' }.empty?
      identity_rows << Identity.new(platform: 'discord', identifier: discord_id)
    end

    user_connections.each do |connection|
      platform = connection['type']
      identifier = connection['id']
      is_verified = connection['verified']

      if is_verified == false
        error_codes << 'steam-not-verified' if platform == 'steam'
        next
      end

      user_id = found_identities[identifier]

      if user_id.nil?
        identity_rows << Identity.new(platform: platform, identifier: identifier)
      end
    end

    # We have to handle the situation where they may have multiple Users created
    users = User.includes(:identities)
                .where(id: found_identities.values)
                .order('created_at DESC')

    if users.empty?
      User.create(identities: identity_rows)
    else
      user = users.first

      identity_rows.map { |row| row.user_id = user.id }
      Identity.import identity_rows

      # Combine all other Users into the first (oldest) User
      users.first.consume_users!(users.slice(1..)) if users.size > 1
    end

    if error_codes.any?
      error_codes = error_codes.join(',')
      return redirect_to "#{FAILURE_URL}?errors=#{error_codes}"
    end

    redirect_to SUCCESS_URL
  end

  private

  def get_token_from_code(code)
    data = {
      'client_id': CLIENT_ID,
      'client_secret': CLIENT_SECRET,
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': DISCORD_REDIRECT_URL,
      'scope': 'identify'
    }

    r = HTTP.headers('Content-Type': 'application/x-www-form-urlencoded')
            .post("#{DISCORD_API}/oauth2/token", form: data)

    r.parse['access_token']
  end

  def get_discord_info(token)
    r = HTTP.auth("Bearer #{token}")
            .get('https://discord.com/api/users/@me')

    r.parse
  end

  def get_user_connections(token)
    r = HTTP.auth("Bearer #{token}")
            .get('https://discord.com/api/users/@me/connections')

    r.parse
  end

  def validate_discord_callback
    is_valid = [
      request&.referrer&.start_with?('https://discord.com'),
      params['code'].present? && params['code'].length == 30
    ]

    render head: :unauthorized unless is_valid.all?
  end
end
