module Admin
  class BaseController < ApplicationController
    layout 'admin'

    before_action :authenticate_admin!

    # Skip standard Pundit verification for admin controllers
    # Admin authorization is handled separately via authenticate_admin!
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    private

    def authenticate_admin!
      return if current_user&.admin?

      flash[:alert] = 'Access denied. Admin privileges required.'
      redirect_to root_path
    end
  end
end
