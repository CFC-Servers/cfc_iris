# frozen_string_literal: true

class IdentitiesController < AuthenticatedController
  def used_steam_ids
    steam_ids = Identities.where(
      platform: 'steam',
      identifier: steam_id_params['steam_ids']
    )

    steam_id_map = steam_ids.each_with_object({}) do |steam_id, id_map|
      id_map[steam_id] = true
    end

    render json: { used_steam_ids: steam_id_map }
  end

  private

  def steam_id_params
    params.require(:steam_ids)
  end
end
