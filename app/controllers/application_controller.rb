class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper :application

  before_action :authenticate_user!
  before_action :check_if_banned

  include Pundit::Authorization
  # Exception to ensure every action contains authorization call
  after_action :verify_authorized, :except => :index, :unless => :devise_controller?
  # Exception to ensure out indices are authorized with scope
  after_action :verify_policy_scoped, :only => :index, :unless => :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :permission_denied unless Rails.env.development?

  def new_session_path scope
    new_user_session_path
  end

private

  def permission_denied
    head 403
  end

  def check_if_banned
    return unless current_user&.banned?

    sign_out current_user
    flash[:alert] = I18n.t('devise.failure.banned')
    redirect_to new_user_session_path
  end
end
