# == Route Map
#
#                                Prefix Verb     URI Pattern                                                     Controller#Action
# user_google_oauth2_omniauth_authorize GET|POST /users/auth/google_oauth2(.:format)                             users/omniauth_callbacks#passthru
#  user_google_oauth2_omniauth_callback GET|POST /users/auth/google_oauth2/callback(.:format)                    users/omniauth_callbacks#google_oauth2
#                      new_user_session GET      /sign_in(.:format)                                              devise/sessions#new
#                  destroy_user_session GET      /sign_out(.:format)                                             devise/sessions#destroy
#           estimation_estimation_items GET      /estimations/:estimation_id/estimation_items(.:format)          estimation_items#index
#                                       POST     /estimations/:estimation_id/estimation_items(.:format)          estimation_items#create
#        new_estimation_estimation_item GET      /estimations/:estimation_id/estimation_items/new(.:format)      estimation_items#new
#       edit_estimation_estimation_item GET      /estimations/:estimation_id/estimation_items/:id/edit(.:format) estimation_items#edit
#            estimation_estimation_item GET      /estimations/:estimation_id/estimation_items/:id(.:format)      estimation_items#show
#                                       PATCH    /estimations/:estimation_id/estimation_items/:id(.:format)      estimation_items#update
#                                       PUT      /estimations/:estimation_id/estimation_items/:id(.:format)      estimation_items#update
#                                       DELETE   /estimations/:estimation_id/estimation_items/:id(.:format)      estimation_items#destroy
#                           estimations GET      /estimations(.:format)                                          estimations#index
#                                       POST     /estimations(.:format)                                          estimations#create
#                        new_estimation GET      /estimations/new(.:format)                                      estimations#new
#                       edit_estimation GET      /estimations/:id/edit(.:format)                                 estimations#edit
#                            estimation GET      /estimations/:id(.:format)                                      estimations#show
#                                       PATCH    /estimations/:id(.:format)                                      estimations#update
#                                       PUT      /estimations/:id(.:format)                                      estimations#update
#                                       DELETE   /estimations/:id(.:format)                                      estimations#destroy
#                                  root GET      /                                                               estimations#index

Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new', :as => :new_user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  resources :estimations do
    resources :estimation_items
    resources :estimation_shares, only: [:index, :create, :destroy] do
      member do
        post :transfer_ownership
      end
    end
  end
  
  root 'estimations#index'
end
