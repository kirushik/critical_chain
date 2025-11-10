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

  scenario 'clicking Login with Google initiates full page navigation (not AJAX)', :playwright do
    visit root_path

    # Track network requests to verify navigation happens
    navigation_url = nil

    page.on('request', ->(request) {
      if request.url.include?('/users/auth/google_oauth2')
        navigation_url = request.url
      end
    })

    # Click the button - this should initiate navigation
    # We expect this to throw a navigation error since we can't actually go to Google
    begin
      page.get_by_role('button', name: 'Login with Google').click(timeout: 3000)
    rescue Playwright::TimeoutError
      # Expected - we're trying to navigate to Google which will timeout
    end

    # Verify that a request to the OAuth endpoint was made
    expect(navigation_url).not_to be_nil, "Expected navigation to /users/auth/google_oauth2 but it never happened"
    expect(navigation_url).to include('/users/auth/google_oauth2')
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
