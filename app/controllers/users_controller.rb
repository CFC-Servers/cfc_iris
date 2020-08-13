# frozen_string_literal: true

class UsersController < ApplicationController
  def find_user
    platforms = params.permit(:steam, :discord)
    platforms.each_pair do |platform, identifier|
      identity = Identity.find_by(platform: platform, identifier: identifier)
      if identity
        return render json: identity.user.as_json(include: :identities)
      end
    end
    render plain: 'User not found', status: 404
  end
end
