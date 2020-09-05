class AuthenticatedController < ApplicationController
  before_action :authenticate

  private

  def authenticate
    token = request.headers["Authentication"]
    existing = ApiToken.where(key: token)

    unless existing
      render head: :unauthorized
    end
  end
end