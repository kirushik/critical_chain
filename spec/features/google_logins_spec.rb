require 'rails_helper'

feature "can login with Google", :type => :feature do
  scenario 'redirects to login page if not authorized' do
    visit root_path
    expect(current_path).to eq new_user_session_path
  end

  scenario 'shows "Login with Google" button when unauthorized' do
    visit root_path
    expect(page).to have_button('Login with Google')
  end

  scenario 'when I click "Login with Google" button, I\'m logged in' do
    pending 'implement user\'s dashboard check here'
  end

  scenario 'won\'t let me in when I\'m not authorized in Google' do
    pending 'implement some useful OmniAuth stubbing here'
  end
end
