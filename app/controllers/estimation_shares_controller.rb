class EstimationSharesController < ApplicationController
  before_action :set_estimation
  before_action :set_estimation_share, only: [:destroy, :transfer_ownership]

  def index
    @estimation_shares = @estimation.estimation_shares.includes(:estimation, :shared_with_user)
    # Authorize using a sample share or a new one
    authorize(@estimation_shares.first || EstimationShare.new(estimation: @estimation))
    skip_policy_scope
  end

  def create
    # Check if email belongs to an existing user
    email = estimation_share_params[:shared_with_email]
    existing_user = User.find_by(email: email) if email.present?

    if existing_user
      @estimation_share = @estimation.estimation_shares.build(
        shared_with_user: existing_user,
        role: estimation_share_params[:role]
      )
    else
      @estimation_share = @estimation.estimation_shares.build(estimation_share_params)
    end

    authorize @estimation_share

    if @estimation_share.save
      respond_to do |format|
        format.html { redirect_to estimation_estimation_shares_path(@estimation), notice: 'Estimation shared successfully.' }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { render :index, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "shares_list",
            ActionController::Base.helpers.content_tag(:script, "alert('#{j(@estimation_share.errors.full_messages.first) || "Share failed"}');")
          ), status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    authorize @estimation_share
    @estimation_share.destroy

    respond_to do |format|
      format.html { redirect_to estimation_estimation_shares_path(@estimation), notice: 'Access revoked successfully.' }
      format.turbo_stream
    end
  end

  def transfer_ownership
    authorize @estimation_share

    # Determine the target user
    target_user = @estimation_share.shared_with_user
    
    unless target_user
      redirect_to estimation_estimation_shares_path(@estimation), 
                  alert: 'Cannot transfer ownership: user has not signed up yet.'
      return
    end

    old_owner = @estimation.user

    ActiveRecord::Base.transaction do
      # Transfer ownership FIRST
      @estimation.update!(user: target_user)

      # Remove the share record as they are now the owner
      @estimation_share.destroy

      # Create a viewer share for the old owner AFTER transfer
      @estimation.estimation_shares.create!(
        shared_with_user: old_owner,
        role: 'viewer'
      )
    end

    redirect_to estimation_estimation_shares_path(@estimation), notice: 'Ownership transferred successfully.'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to estimation_estimation_shares_path(@estimation), alert: "Transfer failed: #{e.message}"
  end

  private

  def set_estimation
    @estimation = Estimation.find(params[:estimation_id])
  end

  def set_estimation_share
    @estimation_share = @estimation.estimation_shares.find(params[:id])
  end

  def estimation_share_params
    params.require(:estimation_share).permit(:shared_with_email, :role)
  end
end
