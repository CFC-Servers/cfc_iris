
class RanksController < ApplicationController
  def update_ranks
    params.require [:users, :realm, :platform]
    users = params[:users]
    realm = params[:realm]
    platform = params[:platform]

    rank_rows = []
    Identity.where(identifier: users.keys, platform: platform).find_each do |identity|
      group = users[identity.identifier]['group']
      next unless group

      rank_rows << {name: group, user_id: identity.user_id, realm: realm}
    end

    Rank.import rank_rows, on_duplicate_key_update: [:name]

    render json: {status: 'success'}, status: 201
  end
end
