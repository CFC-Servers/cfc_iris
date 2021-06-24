# frozen_string_literal: true

class UsersController < AuthenticatedController
  def find_user
    users = find_users_by_identities(find_params)
    users_data = users.as_json(include: %i[identities ranks])

    render json: { users: users_data }
  end

  def get
    user = User.find_by(id: params[:id])
    return render json: { error: 'User not found' }, status: 404 unless user

    render json: { user: user.to_json(include: %i[identities ranks]) }
  end

  def reset
    users = find_users_by_identities(find_params)

    users_data = users.as_json
    Rails.logger.info "Deleting the following users:"
    Rails.logger.info users_data

    users.destroy_all

    render json: { deleted_users: users_data }
  end

  private

  def find_params
    params.permit(identities: %i[identifier platform])
  end

  def find_users_by_identities(identities)
    user_ids = identities.inject(Identity.includes(:user).none) do |memo, pair|
      memo.or(Identity.where(pair.slice(:identifier, :platform)))
    end.pluck(:user_id)

    User.where(id: user_ids)
  end
end
