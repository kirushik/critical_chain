# == Schema Information
#
# Table name: estimations
#
#  id            :integer          not null, primary key
#  title         :string
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tracking_mode :boolean          default(FALSE), not null
#
# Indexes
#
#  index_estimations_on_user_id  (user_id)
#

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
    @estimation = Estimation.includes(
      estimation_items: :estimation,
      estimation_shares: :shared_with_user,
      :user
    ).find(params[:id]).decorate
    authorize @estimation
    
    # Track last access for shared users
    if current_user.id != @estimation.user_id
      share = @estimation.share_for(current_user)
      share&.touch_last_accessed
    end
  end

  def destroy
    @estimation = Estimation.find(params[:id])
    authorize @estimation
    @estimation.destroy

    redirect_to estimations_path unless request.xhr?
  end

  def update
    @estimation = Estimation.find(params[:id])
    authorize @estimation, :update?
    result = @estimation.update(estimation_params)

    respond_to do |format|
      format.turbo_stream do
        if result
          render :update
        else
          render turbo_stream: turbo_stream.append(
            "estimation_title",
            ActionController::Base.helpers.content_tag(:script, "alert('#{j(@estimation.errors.full_messages.first) || "Update failed"}');")
          ), status: :unprocessable_entity
        end
      end
      format.html do
        redirect_to estimation_path(@estimation)
      end
    end
  end

  private
  def estimation_params
    params.require(:estimation).permit(:title, :tracking_mode)
  end
end
