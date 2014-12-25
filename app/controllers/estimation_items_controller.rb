class EstimationItemsController < ApplicationController
  def create
    EstimationItem.create!(estimation_item_params)
    redirect_to estimation_path(params[:estimation_id]) unless request.xhr?
  end

  private
  def estimation_item_params
    params.permit(:title, :value, :estimation_id)
  end
end
