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
  skip_before_action :authenticate_user!, only: [:public_show]

  def create
    estimation = Estimation.new(estimation_params)
    estimation.user = current_user
    authorize estimation
    estimation.save!

    redirect_to estimation_path(estimation)
  end

  def index
    @estimations = policy_scope(Estimation)
                     .includes(:estimation_items)
                     .all
                     .decorate
  end

  def show
    @estimation = Estimation.includes(
      :user,
      :estimation_items,
      estimation_shares: :shared_with_user
    ).find(params[:id]).decorate
    authorize @estimation

    # Track last access for shared users
    if current_user.id != @estimation.user_id
      share = @estimation.share_for(current_user)
      share&.touch_last_accessed
    end

    # Redirect to canonical URL with share token for easy copy-paste sharing
    if @estimation.public_sharing_enabled? && params[:share_token].blank?
      redirect_to public_estimation_path(@estimation, @estimation.share_token)
    end
  end

  def public_show
    @estimation = Estimation.includes(:estimation_items).find(params[:id])

    # Authenticated editor: show full editable view
    if current_user && @estimation.can_edit?(current_user)
      authorize @estimation, :show?
      @estimation = @estimation.decorate

      # Track last access for shared users
      if current_user.id != @estimation.user_id
        share = @estimation.share_for(current_user)
        share&.touch_last_accessed
      end

      # Redirect to fresh token if stale
      if @estimation.share_token != params[:share_token] && @estimation.public_sharing_enabled?
        redirect_to public_estimation_path(@estimation, @estimation.share_token)
        return
      end

      render :show
      return
    end

    # Anonymous/unauthorized: verify token
    if @estimation.share_token.present? && params[:share_token] == @estimation.share_token
      skip_authorization
      @estimation = @estimation.decorate
      render :public_show
    else
      skip_authorization
      redirect_to new_user_session_path
    end
  end

  def rotate_share_token
    @estimation = Estimation.find(params[:id])
    authorize @estimation, :manage_shares?
    @estimation.rotate_share_token!
    redirect_to estimation_estimation_shares_path(@estimation), notice: 'Share link regenerated. Old links no longer work.'
  end

  def destroy
    @estimation = Estimation.find(params[:id])
    authorize @estimation
    @estimation.destroy

    redirect_to estimations_path unless request.xhr?
  end

  def update
    @estimation = Estimation.find(params[:id])
    authorize @estimation, :update_metadata?
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
