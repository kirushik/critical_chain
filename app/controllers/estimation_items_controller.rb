# == Schema Information
#
# Table name: estimation_items
#
#  id            :integer          not null, primary key
#  value         :integer          default(0)
#  title         :string
#  estimation_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  fixed         :boolean          default(FALSE), not null
#  quantity      :integer          default(1), not null
#  actual_value  :float
#
# Indexes
#
#  index_estimation_items_on_estimation_id  (estimation_id)
#

class EstimationItemsController < ApplicationController
  include ActionView::RecordIdentifier

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
    result = @estimation_item.update(estimation_item_params)

    @estimation.reload

    respond_to do |format|
      format.turbo_stream do
        if result
          # Render the turbo stream template
          render :update
        else
          render turbo_stream: turbo_stream.append(
            dom_id(@estimation),
            ActionController::Base.helpers.content_tag(:script, "alert('#{j(@estimation_item.errors.full_messages.first) || "Update failed"}');")
          ), status: :unprocessable_entity
        end
      end
      format.js
      format.html do
        redirect_to estimation_path(@estimation)
      end
    end
  end

  private

  def estimation_item_params
    params.require(:estimation_item).permit(:title, :value, :quantity, :fixed, :actual_value, :order)
  end
end
