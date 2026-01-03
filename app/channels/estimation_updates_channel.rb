class EstimationUpdatesChannel < ApplicationCable::Channel
  def subscribed
    estimation = Estimation.find(params[:estimation_id])
    
    # Check if user has permission to view this estimation
    if estimation.can_view?(current_user)
      stream_from "estimation_#{estimation.id}"
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
