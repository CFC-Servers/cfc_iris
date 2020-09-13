# frozen_string_literal: true

class RanksController < AuthenticatedController
  def update_ranks
    params.require %i[users realm platform]
    #users = JSON.parse(LZMA.decompress(params[:users]))
    users = JSON.parse(params[:users])
    realm = params[:realm]
    platform = params[:platform]

    # TODO: Validate this data and raise if problem
    RanksProcessingJob.perform_later(users, realm, platform)

    render head: :accepted
  end
end
