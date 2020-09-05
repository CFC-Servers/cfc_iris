# frozen_string_literal: true

class UsersController < AuthenticatedController
  def find_user
    platforms = params.permit(:steam, :discord)
    platforms.each_pair do |platform, identifier|
      identity = Identity.find_by(platform: platform, identifier: identifier)
      if identity
        return render json: identity.user.as_json(include: [:identities, :ranks])
      end
    end
    render json: {error: 'User not found'}, status: 404
  end

  def get
    user = User.find_by(id: params[:id])
    return render plain: 'User not found', status: 404 unless user

    render json: user.as_json(include: [:identities, :ranks])
  end
end
