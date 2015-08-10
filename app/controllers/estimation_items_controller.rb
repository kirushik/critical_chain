class EstimationItemsController < ApplicationController
  def create
    @estimation = Estimation.find(params[:estimation_id]).decorate

    @estimation_item = EstimationItem.new(estimation_item_params)
    @estimation_item.estimation = @estimation

    authorize @estimation, :update?

    @estimation_item.save!

    redirect_to estimation_path(@estimation) unless request.xhr?
  end

  def destroy
    @estimation = Estimation.find(params[:estimation_id]).decorate
    @estimation_item = EstimationItem.find(params[:id])

    authorize @estimation, :update?
    @estimation_item.destroy!

    redirect_to estimation_path(@estimation) unless request.xhr?
  end

  def update
    @estimation = Estimation.find(params[:estimation_id]).decorate
    @estimation_item = EstimationItem.find(params[:id])

    authorize @estimation, :update?
    result = @estimation_item.update_attributes(estimation_item_params)

    @estimation.reload

    if request.xhr?
      # return render plain: @estimation_item.errors.first, status: :bad_request unless result

      respond_to do |format|
        format.json do
          render json: {success: result,
            msg: @estimation_item.errors.full_messages.first,
            additionalValues: {
              sum: @estimation.sum,
              buffer: @estimation.buffer,
              total: @estimation.total,
              actual_sum: @estimation.actual_sum,
              buffer_health: @estimation.buffer_health,
              buffer_health_class: @estimation.buffer_health_class
            }}
        end
        format.js
      end
    else
      redirect_to estimation_path(@estimation)
    end
  end

  private
  def estimation_item_params
    params.require(:estimation_item).permit(:title, :value, :quantity, :fixed, :actual_value)
  end
end
