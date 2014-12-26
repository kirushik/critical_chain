class EstimationsController < ApplicationController
  def create
    estimation = Estimation.new(estimation_params)
    estimation.user = current_user
    estimation.save!

    redirect_to estimation_path(estimation)
  end

  def index
    @estimations = current_user.estimations
  end

  def show
    @estimation = Estimation.find(params[:id])
  end

  private
  def estimation_params
    params.require(:estimation).permit(:title)
  end
end
