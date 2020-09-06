
class RanksController < AuthenticatedController
  def update_ranks
    params.require %i[users realm platform]
    users = params[:users]
    realm = params[:realm]
    platform = params[:platform]

    # TODO: Validate this data and raise if problem
    RanksProcessingJob.perform_later(users, realm, platform)

    render json: { status: 'success' }, status: 201
  end
end
