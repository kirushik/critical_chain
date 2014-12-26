class EstimationItemsController < ApplicationController
  def create
    @estimation = Estimation.find(params[:estimation_id])

    @estimation_item = EstimationItem.new(estimation_item_params)
    @estimation_item.estimation = @estimation
    @estimation_item.save!

    redirect_to estimation_path(@estimation) unless request.xhr?
  end

  private
  def estimation_item_params
    params.require(:estimation_item).permit(:title, :value)
  end
end
