# frozen_string_literal: true

require 'http'

DISCORD_API = 'https://discord.com/api/v6'
DISCORD_REDIRECT_URL = 'https://iris.cfcservers.org/api/callbacks/discord'
CREDENTIALS = Rails.application.credentials

def log(l)
  Rails.logger.info(l)
end

class CallbacksController < ApplicationController
  before_action :validate_discord_callback, only: [:receive_discord_callback]
  before_action :new_callback_session

  def receive_discord_callback
    processed = process_connections
    results = processed[:results]
    new_identities = processed[:identity_rows]

    if user_id_map[discord_id].nil?
      new_identities << Identity.new(
        platform: :discord,
        identifier: discord_id
      )
    end

    Rails.logger.info(user_id_map)

    users = User.includes(:identities)
                .where(id: user_id_map.values.flatten)
                .order(created_at: :desc)

    log "Found #{users.count} "

    users.each do |l|
      Rails.logger.info("User: #{l.to_json}")
    end

    # TODO: DRY this up
    users.yield_self do |oldest_user, *newer_users|
      log "Oldest user: #{oldest_user.inspect}"
      log "Newer users count: #{newer_users.count}"

      if oldest_user.nil?
        log "Oldest user is nil, creating a new user and assigning #{new_identities.count} identities"
        new_user = User.create
        new_identities.map { |row| row.user_id = new_user.id }

        Identity.import new_identities, on_duplicate_key_ignore: true
        break
      end

      log "Oldest user is valid, assigning/importing #{new_identities.count} identities and consuming #{newer_users.count} other users.."
      new_identities.map { |row| row.user_id = oldest_user.id }
      Identity.import new_identities, on_duplicate_key_ignore: true

      oldest_user.consume_users! newer_users if newer_users.any?
    end

    @callback_session.update(results: results.to_json)

    redirect_to @callback_url
  end

  private

  def process_connections
    log 'Processing connections'

    processed_connections = user_connections.each_with_object(
      results: [],
      identity_rows: []
    ) do |connection, processed|
      platform = connection[:platform]
      identifier = connection[:identifier]

      log "Processing: #{identifier}@#{platform}"

      if connection[:verified] == false
        log "#{platform} is not verified!"
        processed[:results] << {
          platform: platform,
          message: 'not-verified'
        }
        next
      end

      message = ''

      if user_id_map[identifier].present?
        log "#{platform} is already linked!"
        message = 'already-linked'
      else
        log "Queuing new Identity for #{platform}!"
        processed[:identity_rows] << Identity.new(
          platform: platform,
          identifier: identifier
        )

        message = 'successfully-linked'
      end

      processed[:results] << {
        platform: platform,
        message: message
      }
    end

    processed_connections[:results] << {
      platform: "discord",
      message: "successfully-linked"
    }

    processed_connections
  end

  def user_id_map
    @user_id_map ||= make_user_id_map
  end

  def make_user_id_map
    # Generate a query to find any Identity with the
    # specific pairs of identifiers and platforms
    identities = user_connections.inject(Identity.none) do |memo, pair|
      memo.or(Identity.where(pair.slice(:identifier, :platform)))
    end

    # { identifier: [user_id, user_id] }
    identities.each_with_object({}) do |identity, hash|
      identifier = identity.identifier
      log "Adding map: #{identifier}:#{identity.user_id}"

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

    req = HTTP.headers('Content-Type': 'application/x-www-form-urlencoded')
    resp = req.post("#{DISCORD_API}/oauth2/token", form: data)
    resp = resp.parse(:json)

    log resp.inspect

    token = resp['access_token']

    token
  end

  def discord_token
    @discord_token ||= discord_token_from_params
  end

  def discord_id
    @discord_id ||= HTTP.auth("Bearer #{discord_token}")
                        .get('https://discord.com/api/users/@me')
                        .parse(:json)['id']
  end

  def user_connections
    return @user_connections if @user_connections

    #@user_connections = HTTP.auth("Bearer #{discord_token}")
    #                        .get('https://discord.com/api/users/@me/connections')
    #                        .parse
    #                        .map do |c|
    #                          {
    #                            identifier: c['id'],
    #                            platform: c['type'],
    #                            verified: c['verified']
    #                          }
    #                        end

    req = HTTP.auth("Bearer #{discord_token}")
              .get('https://discord.com/api/users/@me/connections')

    resp = req.parse(:json)
    log resp.inspect

    @user_connections = resp.map do |c|
      log c
      {
        identifier: c['id'],
        platform: c['type'],
        verified: c['verified']
      }
    end

    @user_connections << {
      identifier: discord_id,
      platform: "discord",
      verified: true
    }

    @user_connections
  end

  def validate_discord_callback
    #log 'Validating discord callback..'
    is_valid = [
      request&.referrer&.start_with?('https://discord.com'),
      params['code'].present? && params['code'].length == 30
    ]

    head :unauthorized unless is_valid.all?

    Rails.logger.info "Discord callback validated"
  end

  def new_callback_session
    #log "Creating new callback session"

    @callback_session = CallbackSession.create(
      referrer: request.referrer,
      params: params.to_json,
      ip: request.remote_ip
    )

    url_base = 'https://cfcservers.org/link'
    @callback_url = "#{url_base}/complete?session=#{@callback_session.uuid}"
  end

  def breakout
    render 'hello' and return
  end
end
