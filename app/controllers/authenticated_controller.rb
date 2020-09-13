# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  before_action :authenticate

  private

  def authenticate
    token = request.headers['Authorization']&.split&.last
    Rails.logger.info('Received request with following headers:')
    Rails.logger.info(request.headers['Authorization'])
    Rails.logger.info(request.headers[:Authorization])
    Rails.logger.info(request.authorization)
    Rails.logger.info(request.env['Authorization'])
    Rails.logger.info('With authorization token of:')
    Rails.logger.info(token)
    Rails.logger.info('')

    existing = ApiToken.find_by(key: token)
    Rails.logger.info(existing)

    head :unauthorized unless existing
  end
end
