# frozen_string_literal: true

class UsersController < AuthenticatedController
  def find_user
    platforms = params.permit(:steam, :discord)

    identity = Identity.find_by(platform: platforms, identifier: identifier)

    if identity
      return render json: { user: identity.user.as_json(include: %i[identities ranks]) }
    end

    render json: { error: 'User not found' }, status: 404
  end

  def get
    user = User.find_by(id: params[:id])
    return render json: { error: 'User not found' }, status: 404 unless user

    render json: { user: user.as_json(include: %i[identities ranks]) }
  end

  def steam_ids
    steam_ids = Identity.where(platform: 'steam').all.pluck(:identifier)
    render json: { steamIDs: steam_ids }
  end
end
