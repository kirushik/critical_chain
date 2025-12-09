class EstimationSharesController < ApplicationController
  before_action :set_estimation
  before_action :set_estimation_share, only: %i[destroy transfer_ownership]

  def index
    load_shares
    @estimation_share = EstimationShare.new(estimation: @estimation)
    authorize(@estimation_shares.first || @estimation_share)
    skip_policy_scope
  end

  def create
    @estimation_share = EstimationShare.new(estimation: @estimation)
    authorize @estimation_share

    email = estimation_share_params[:shared_with_email].to_s.strip.downcase
    existing_user = email.present? ? User.where('LOWER(email) = ?', email).first : nil

    if (existing_share = existing_share_for(email, existing_user))
      flash.now[:notice] = "#{existing_share.display_email} already has access."
      reset_form_state
      respond_with_updates(status: :ok)
      return
    end

    @estimation_share.assign_attributes(share_attributes(existing_user, email))

    if @estimation_share.save
      flash.now[:notice] = 'Estimation shared successfully.'
      reset_form_state
      respond_with_updates(status: :ok)
    else
      @estimation_share.shared_with_email = email if email.present?
      flash.now[:alert] = @estimation_share.errors.full_messages.first || 'Share failed'
      load_shares
      respond_with_updates(status: :unprocessable_entity)
    end
  end

  def destroy
    authorize @estimation_share
    @estimation_share.destroy

    flash.now[:notice] = 'Access revoked successfully.'
    reset_form_state
    respond_with_updates(status: :ok)
  end

  def transfer_ownership
    authorize @estimation_share

    target_user = @estimation_share.shared_with_user
    unless target_user
      redirect_to estimation_estimation_shares_path(@estimation),
                  alert: 'Cannot transfer ownership: user has not signed up yet.'
      return
    end

    ActiveRecord::Base.transaction do
      old_owner = @estimation.user
      @estimation.update!(user: target_user)
      @estimation_share.destroy
      @estimation.estimation_shares.find_or_create_by!(shared_with_user: old_owner)
    end

    redirect_to estimation_path(@estimation), notice: 'Ownership transferred successfully.'
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

  def load_shares
    @estimation_shares = @estimation.estimation_shares
                                     .includes(:estimation, :shared_with_user)
                                     .order(:created_at)
  end

  def existing_share_for(email, existing_user)
    return if email.blank? && existing_user.blank?

    scope = @estimation.estimation_shares
    share = scope.find_by(shared_with_user: existing_user) if existing_user
    share ||= scope.where.not(shared_with_email: nil)
                   .find_by(shared_with_email: email) if email.present?
    share
  end

  def share_attributes(existing_user, email)
    if existing_user
      { shared_with_user: existing_user }
    else
      { shared_with_email: email.presence }
    end
  end

  def reset_form_state
    @estimation_share = EstimationShare.new(estimation: @estimation)
    load_shares
  end

  def respond_with_updates(status:)
    respond_to do |format|
      format.html do
        if status == :ok
          %i[notice alert].each do |type|
            value = flash.now[type]
            flash[type] = value if value.present?
          end
          redirect_to estimation_estimation_shares_path(@estimation)
        else
          render :index, status: status
        end
      end
      format.turbo_stream { render status: status }
    end
  end

  def estimation_share_params
    params.require(:estimation_share).permit(:shared_with_email)
  end
end
