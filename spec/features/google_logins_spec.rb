require 'rails_helper'

feature "can login with Google", :type => :feature do
  before :each do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  scenario 'redirects to login page if not authorized' do
    visit root_path
    expect(current_path).to eq(new_user_session_path)
  end

  scenario 'shows "Login with Google" button when unauthorized' do
    visit root_path
    expect(page).to have_link('Login with Google')
  end

  scenario 'when I click "Login with Google" button, I\'m logged in' do
    OmniAuth.config.add_mock :google_oauth2, uid: Faker::Number.number(25), info: {email: Faker::Internet.email}

    visit root_path
    click_link('Login with Google')

    expect(page).to have_text('Successfully authenticated from Google account.')
  end

  scenario 'won\'t let me in when I\'m not authorized in Google' do
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

    visit root_path
    click_link('Login with Google')

    expect(page).to have_text('Could not authenticate')
  end
end
