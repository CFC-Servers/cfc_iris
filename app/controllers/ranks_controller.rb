
class RanksController < ApplicationController
  def update_ranks
    params.require [:users, :realm, :platform]
    rank_rows = []
    params[:users].each_pair do |identifier, rank_data|
      identity = Identity.find_by identifier: identifier, platform: params[:platform]
      next unless identity

      rank_rows << {name: rank_data['group'], user_id: identity.user_id, realm: params[:realm] }
    end

    Rank.import rank_rows, on_duplicate_key_update: [:name] unless rank_rows.length == 0

    render plain: 'Ranks updated', status: 202
  end
end
