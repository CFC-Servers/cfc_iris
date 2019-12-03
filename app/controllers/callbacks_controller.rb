# frozen_string_literal: true

require 'http'

API_ENDPOINT = 'https://discordapp.com/api/v6'
CLIENT_ID = '650800239157968896'
CLIENT_SECRET = Rails.application.credentials.client_secret
REDIRECT_URL = 'https://iris.cfcservers.org/api/callbacks/discord'
CFC_BOT_TOKEN = Rails.application.credentials.cfc_bot_token

SUCCESS_URL = 'https://cfcservers.org/link/success'
FAILURE_URL = 'https://cfcservers.org/link/failure'

class CallbacksController < ApplicationController
  before_action :validate_discord_callback, only: [:receive_discord_callback]
  before_action :validate_cfc_bot_callback, only: [:receive_cfc_bot_callback]

  def receive_discord_callback
    code = params['code']

    token = get_token_from_code(code)

    user_info = get_user_info(token)
    discord_id = user_info['id']

    error_codes = []

    user_connections = get_user_connections(token)
    user_connections.each do |connection|
      next unless connection['type'] == 'steam'
      next unless connection['verified']

      steam_id = connection['id']

      steam_id_used = User.find_by(steam_id: steam_id)
      discord_id_used = User.find_by(discord_id: discord_id)

      error_codes.push('used-steam-id') if steam_id_used
      error_codes.push('used-discord-id') if discord_id_used

      break if steam_id_used || discord_id_used

      User.create(steam_id: steam_id, discord_id: discord_id)

      return redirect_to SUCCESS_URL
    end

    error_codes.push('discord-missing-steam') if error_codes.empty?

    error_codes = error_codes.join(',')
    redirect_to "#{FAILURE_URL}?errors=#{error_codes}"
  end

  def receive_cfc_bot_callback
    steam_id = params['steam_id']
    discord_id = params['discord_id']

    error_codes = []

    steam_id_used = User.find_by(steam_id: steam_id)
    discord_id_used = User.find_by(discord_id: discord_id)

    error_codes.push('used-steam-id') if steam_id_used
    error_codes.push('used-discord-id') if discord_id_used

    render json: { status: 'failure', errors: error_codes } if error_codes.any?

    User.create(steam_id: steam_id, discord_id: discord_id)

    render json: { status: 'success' }
  end

  private

  def get_token_from_code(code)
    data = {
      'client_id': CLIENT_ID,
      'client_secret': CLIENT_SECRET,
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': REDIRECT_URL,
      'scope': 'identify'
    }

    r = HTTP.headers('Content-Type': 'application/x-www-form-urlencoded')
            .post("#{API_ENDPOINT}/oauth2/token", form: data)

    r.parse['access_token']
  end

  def get_user_info(token)
    r = HTTP.auth("Bearer #{token}")
            .get('https://discordapp.com/api/users/@me')

    r.parse
  end

  def get_user_connections(token)
    r = HTTP.auth("Bearer #{token}")
            .get('https://discordapp.com/api/users/@me/connections')

    r.parse
  end

  def validate_discord_callback
    is_valid = [
      request&.referrer&.start_with?('https://discordapp.com'),
      params['code'].present? && params['code'].length == 30
    ]

    render status: :unauthorized unless is_valid.all?
  end

  def validate_cfc_bot_callback
    is_valid = [
      request.form['token'] == CFC_BOT_TOKEN
    ]

    render status: :unauthorized unless is_valid.all?
  end
end
