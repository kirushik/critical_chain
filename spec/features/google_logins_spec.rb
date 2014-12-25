require 'rails_helper'

feature "can login with Google", :type => :feature do
  scenario 'shows "Login with Google" button on the login page' do
    visit root_path
    expect(page).to have_button('Login with Google')
  end
end
