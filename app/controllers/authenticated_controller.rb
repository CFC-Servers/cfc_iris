class AuthenticatedController < ApplicationController
  before_action :authenticate

  private

  def authenticate
    token = request.headers["Authorization"]&.split.last
    existing = ApiToken.where(key: token)

    unless existing
      render head: :unauthorized
    end
  end
end
