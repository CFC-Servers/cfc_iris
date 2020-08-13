
class RanksController < ApplicationController
  def update_ranks

    params['users'].each_pair do |identifier, rank_data|
      identity = Identity.find_by(identifier: identifier)
      next unless identity

      user = identity.user
      next unless user

      Rank.where(user_id: user.id).delete_all
      Rank.create(name: rank_data['group'], user_id: user.id, realm: params['realm'])
    end
    render plain: 'Ranks updated', status: 202
  end
end
