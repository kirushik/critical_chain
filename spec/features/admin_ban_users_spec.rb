require 'rails_helper'

feature "Admin Ban/Unban Users", type: :feature do
  around do |example|
    original_value = ENV['ADMIN_EMAILS']
    ENV['ADMIN_EMAILS'] = 'admin@example.com'
    example.run
    ENV['ADMIN_EMAILS'] = original_value
  end

  let(:admin) { FactoryBot.create(:user, email: 'admin@example.com') }

  feature "Banning Users" do
    let!(:target_user) { FactoryBot.create(:user, email: 'target@example.com') }

    scenario 'admin can ban a regular user' do
      login_as admin
      visit admin_users_path

      within('tr', text: 'target@example.com') do
        click_button 'Ban'
      end

      expect(page).to have_text("User target@example.com has been banned")
      within('tr', text: 'target@example.com') do
        expect(page).to have_selector('.tag.is-danger', text: /Banned/)
        expect(page).to have_button('Unban')
      end
    end

    scenario 'admin cannot ban another admin' do
      # Temporarily add second admin to ENV
      original_value = ENV['ADMIN_EMAILS']
      ENV['ADMIN_EMAILS'] = 'admin@example.com,admin2@example.com'

      other_admin = FactoryBot.create(:user, email: 'admin2@example.com')

      login_as admin
      visit admin_users_path

      within('tr', text: 'admin2@example.com') do
        expect(page).not_to have_button('Ban')
      end

      ENV['ADMIN_EMAILS'] = original_value
    end

    scenario 'ban button is not shown for admin users' do
      login_as admin
      visit admin_users_path

      within('tr', text: 'admin@example.com') do
        expect(page).not_to have_button('Ban')
        expect(page).not_to have_button('Unban')
      end
    end
  end

  feature "Unbanning Users" do
    let!(:banned_user) { FactoryBot.create(:user, :banned, email: 'banned@example.com') }

    scenario 'admin can unban a banned user' do
      login_as admin
      visit admin_users_path

      within('tr', text: 'banned@example.com') do
        click_button 'Unban'
      end

      expect(page).to have_text("User banned@example.com has been unbanned")
      within('tr', text: 'banned@example.com') do
        expect(page).to have_selector('.tag.is-success', text: 'Active')
        expect(page).to have_button('Ban')
      end
    end
  end

  feature "Banned User Session Termination" do
    scenario 'banned user is logged out on next page load' do
      target_user = FactoryBot.create(:user, email: 'target@example.com')

      # First, log in as target user and visit a page
      login_as target_user
      visit root_path
      expect(page).to have_link('Sign out')

      # Now ban the user (simulating admin action)
      target_user.ban!(admin)

      # When the banned user tries to navigate, they should be logged out
      visit root_path

      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_text('Your account has been suspended')
    end
  end

  feature "Banned User Cannot Sign In" do
    scenario 'banned user cannot authenticate via OAuth' do
      banned_user = FactoryBot.create(:google_user, :banned, email: 'banned@example.com')

      OmniAuth.config.add_mock :google_oauth2,
                               uid: banned_user.uid,
                               info: { email: 'banned@example.com' }

      visit root_path
      click_button 'Login with Google'

      expect(page).to have_text('Your account has been suspended')
    end
  end
end
