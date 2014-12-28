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

  def destroy
    @estimation = Estimation.find(params[:id])
    authorize @estimation
    @estimation.destroy

    redirect_to estimations_path unless request.xhr?
  end

  private
  def estimation_params
    params.require(:estimation).permit(:title)
  end
end
