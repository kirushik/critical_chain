# == Route Map
#
#                  Prefix Verb     URI Pattern                            Controller#Action
# user_omniauth_authorize GET|POST /users/auth/:provider(.:format)        users/omniauth_callbacks#passthru {:provider=>/google_oauth2/}
#  user_omniauth_callback GET|POST /users/auth/:action/callback(.:format) users/omniauth_callbacks#:action
#        new_user_session GET      /sign_in(.:format)                     devise/sessions#new
#    destroy_user_session GET      /sign_out(.:format)                    devise/sessions#destroy
#                    root GET      /                                      welcome#login
#

Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new', :as => :new_user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  
  root 'welcome#login'
end
