module Admin
  class UsersController < BaseController
    def index
      @users = User.order(created_at: :desc)
                   .select(:id, :email, :sign_in_count, :last_sign_in_at,
                           :created_at, :banned_at, :banned_by_email)
    end

    def ban
      @user = User.find(params[:id])

      if @user.admin?
        flash[:alert] = 'Cannot ban admin users.'
        redirect_to admin_users_path
        return
      end

      @user.ban!(current_user)
      flash[:notice] = "User #{@user.email} has been banned."
      redirect_to admin_users_path
    end

    def unban
      @user = User.find(params[:id])
      @user.unban!
      flash[:notice] = "User #{@user.email} has been unbanned."
      redirect_to admin_users_path
    end
  end
end
