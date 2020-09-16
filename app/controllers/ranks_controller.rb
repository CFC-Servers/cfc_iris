# frozen_string_literal: true

class RanksController < AuthenticatedController
  def update_ranks
    Rails.logger.info(update_params.inspect)
    users = update_params[:users]
    realm = update_params[:realm]
    platform = update_params[:platform]

    # TODO: Validate this data and raise if problem
    RanksProcessingJob.perform_later(users, realm, platform)

    render head: :accepted
  end

  def update_params
    params.permit(:realm, :platform, users: {})
  end
end
