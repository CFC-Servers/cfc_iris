# frozen_string_literal: true
ALLOWED_PLATFORMS = %w[steam discord]
class UsersController < ApplicationController
  def find_user
    platforms = params.permit(:steam, :discord)
    platforms.each_pair do |platform, identifier|
      next unless ALLOWED_PLATFORMS.include? platform
      identity = Identity.find_by(platform: platform, identifier: identifier)
      if identity
        return render json: identity.user.as_json(include: :identities)
      end
    end
    render plain: 'User not found', status: 404
  end
end
