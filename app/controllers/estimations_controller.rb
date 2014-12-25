class EstimationsController < ApplicationController
  def index
    @estimations = current_user.estimations
  end

  def show
    @estimation = Estimation.find(params[:id])
  end
end
