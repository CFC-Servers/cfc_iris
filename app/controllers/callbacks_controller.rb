# frozen_string_literal: true

require 'http'

DISCORD_API = 'https://discord.com/api/v6'
DISCORD_REDIRECT_URL = 'https://iris.cfcservers.org/api/callbacks/discord'
CREDENTIALS = Rails.application.credentials

class CallbacksController < ApplicationController
  before_action :validate_discord_callback, only: [:receive_discord_callback]
  before_action :new_callback_session

  def receive_discord_callback
    results, new_identities = process_connections

    if user_id_map[discord_id].nil?
      new_identities << Identity.new(
        platform: :discord,
        identifier: discord_id
      )
    end

    users = User.includes(:identities)
                .where(id: user_ids.values)
                .order('created_at DESC')

    users.yield_self do |oldest_user, *newer_users|
      break User.create(identities: new_identities) if oldest_user.nil?

      new_identities.map { |row| row.user_id = oldest_user.id }
      Identity.import new_identities

      oldest_user.consume_users! newer_users if newer_users.any?
    end

    @callback_session.update(results: results.to_json)

    redirect_to @callback_url
  end

  private

  def process_connections
    results = []
    identity_rows = []

    user_connections.each do |connection|
      platform = connection[:type]
      identifier = connection[:id]
      is_verified = connection[:verified]

      if is_verified == false
        results << { platform: platform, error: 'not-verified' }
        next
      end

      message = ''

      if user_id_map[identifier].present?
        message = 'already-linked'
      else
        identity_rows << Identity.new(
          platform: platform,
          identifier: identifier
        )

        message = 'linked-successfully'
      end

      results << { platform: platform, message: message }
    end

    [results, identity_rows]
  end

  def user_id_map
    @user_id_map ||= make_user_id_map
  end

  def make_user_id_map
    # Array of hashes to be used in a where chain
    connection_pairs = user_connections.map do |c|
      { identifier: c[:id], platform: c[:type] }
    end

    # Generate a query to find any Identity with the
    # specific pairs of identifiers and platforms
    identities = connection_pairs.inject(Identity.none) do |memo, pair|
      memo.or(Identity.where(pair))
    end

    # { identifier: [user_id, user_id] }
    identities.each_with_object({}) do |hash, identity|
      identifier = identity.identifier

      hash[identifier] ||= []
      hash[identifier] << identity.user_id
    end
  end

  def discord_token_from_params
    data = {
      client_id: CREDENTIALS.discord_client_id,
      client_secret: CREDENTIALS.discord_client_secret,
      grant_type: :authorization_code,
      code: params['code'],
      redirect_uri: DISCORD_REDIRECT_URL,
      scope: :identify
    }

    HTTP.headers('Content-Type': 'application/x-www-form-urlencoded')
        .post("#{DISCORD_API}/oauth2/token", form: data)
        .parse['access_token']
  end

  def discord_token
    @discord_token ||= discord_token_from_params
  end

  def discord_id
    @discord_id ||= HTTP.auth("Bearer #{discord_token}")
                        .get('https://discord.com/api/users/@me')
                        .parse['id']
  end

  def user_connections
    @user_connections ||= HTTP.auth("Bearer #{discord_token}")
                              .get('https://discord.com/api/users/@me/connections')
                              .parse
                              .symbolize_keys
  end

  def validate_discord_callback
    is_valid = [
      request&.referrer&.start_with?('https://discord.com'),
      params['code'].present? && params['code'].length == 30
    ]

    render head: :unauthorized unless is_valid.all?
  end

  def new_callback_session
    @callback_session = CallbackSession.create(
      referrer: request.referrer,
      params: params.to_json,
      ip: request.remote_ip
    )

    url_base = 'https://cfcservers.org/link/success'
    @callback_url = "#{url_base}/success?session=#{@callback_session.uuid}"
  end
end
