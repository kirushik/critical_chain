require 'rails_helper'

feature "can login with Google", :type => :feature do
  def log_me_in
    visit root_path
    click_button('Login with Google')
  end

  before :each do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  let(:user) { FactoryBot.create(:user) }

  scenario 'redirects to login page if not authorized' do
    visit root_path
    expect(current_path).to eq(new_user_session_path)
  end

  scenario 'shows "Login with Google" button when unauthorized' do
    visit root_path
    expect(page).to have_button('Login with Google')
  end

  scenario 'when I click "Login with Google" button, I\'m logged in' do
    OmniAuth.config.add_mock :google_oauth2, uid: Faker::Number.number(digits: 25), info: {email: Faker::Internet.email}

    log_me_in

    expect(page).to have_text('Successfully authenticated from Google account.')
  end

  scenario 'shows "Sign out" link if authorized' do
    login_as user
    visit root_path

    expect(page).to have_link('Sign out')
  end

  scenario 'when I click "Sign out" button I\'m logged out' do
    login_as user
    visit root_path

    click_link "Sign out"

    expect(page).to have_button('Login with Google')
  end

  scenario 'won\'t let me in when I\'m not authorized in Google' do
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

    log_me_in

    expect(page).to have_text('Could not authenticate')
  end
end
