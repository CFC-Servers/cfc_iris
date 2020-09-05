# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  before_action :authenticate

  private

  def authenticate
    token = request.headers['Authorization']&.split&.last
    existing = ApiToken.find_by(key: token)

    render head: :unauthorized unless existing
  end
end
