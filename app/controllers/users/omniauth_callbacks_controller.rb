class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env['omniauth.auth'], current_user)

    raise 'Failed to get persisted user from omniauth data' unless @user.persisted?

    if @user.banned?
      flash[:alert] = I18n.t('devise.failure.banned')
      redirect_to new_user_session_path
      return
    end

    flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
    sign_in_and_redirect @user, event: :authentication
  end
end