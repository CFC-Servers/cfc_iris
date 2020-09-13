# frozen_string_literal: true

class CallbackSessionsController < ApplicationController
  def results
    session = CallbackSession.find_by(uuid: params['uuid'])
    head :not_found unless session

    session.update(active: false)
    render json: { results: session.transform_results }
  end
end
