class EstimationsController < ApplicationController
  def create
    estimation = Estimation.new(estimation_params)
    estimation.user = current_user
    authorize estimation
    estimation.save!

    redirect_to estimation_path(estimation)
  end

  def index
    @estimations = policy_scope(Estimation).all.decorate
  end

  def show
    @estimation = Estimation.find(params[:id]).decorate
    authorize @estimation
  end

  private
  def estimation_params
    params.require(:estimation).permit(:title)
  end
end
