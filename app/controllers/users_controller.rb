# frozen_string_literal: true

class UsersController < AuthenticatedController
  def find_user
    user_ids = find_params['identities'].inject(Identity.includes(:user).none) do |memo, pair|
      memo.or(Identity.where(pair.slice(:identifier, :platform)))
    end.pluck(:user_id)

    users_data = User.where(id: user_ids).as_json(include: %i[identities ranks])

    render json: { users: users_data }
  end

  def get
    user = User.find_by(id: params[:id])
    return render json: { error: 'User not found' }, status: 404 unless user

    render json: { user: user.to_json(include: %i[identities ranks]) }
  end

  def find_params
    params.permit(identities: %i[identifier platform])
  end
end
