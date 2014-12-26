class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper :application

  before_action :authenticate_user!

  include Pundit
  # Exception to ensure every action contains authorization call
  after_action :verify_authorized, :except => :index
  # Exception to ensure out indices are authorized with scope
  after_action :verify_policy_scoped, :only => :index

  rescue_from Pundit::NotAuthorizedError, with: :permission_denied unless Rails.env.development?

  def new_session_path scope
    new_user_session_path
  end

private
 
  def permission_denied
    head 403
  end
end
