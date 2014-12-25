class WelcomeController < ApplicationController
  def index
    @estimations = current_user.estimations
  end
end
