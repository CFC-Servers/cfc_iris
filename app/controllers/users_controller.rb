# frozen_string_literal: true

class UsersController < AuthenticatedController
  def find_user
    platforms = params.permit(:steam, :discord)
    identity = Identity.find_by(platform: platforms, identifier: identifier)

    render json: { error: 'User not found' }, status: 404 unless identity

    identity_user = identity.user.as_json(include: %i[identities ranks])

    render json: { user: identity_user }
  end

  def get
    user = User.find_by(id: params[:id])
    return render json: { error: 'User not found' }, status: 404 unless user

    render json: { user: user.as_json(include: %i[identities ranks]) }
  end
end
