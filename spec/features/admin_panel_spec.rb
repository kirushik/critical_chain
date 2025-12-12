require 'rails_helper'

feature "Admin Panel", type: :feature do
  around do |example|
    original_value = ENV['ADMIN_EMAILS']
    ENV['ADMIN_EMAILS'] = 'admin@example.com'
    example.run
    ENV['ADMIN_EMAILS'] = original_value
  end

  let(:admin) { FactoryBot.create(:user, email: 'admin@example.com') }
  let(:regular_user) { FactoryBot.create(:user, email: 'regular@example.com') }

  feature "Access Control" do
    scenario 'admin can access admin dashboard' do
      login_as admin
      visit admin_root_path

      expect(page).to have_selector('h1', text: 'Dashboard')
      expect(page).to have_current_path(admin_root_path)
    end

    scenario 'admin can access admin users page' do
      login_as admin
      visit admin_users_path

      expect(page).to have_selector('h1', text: 'Users')
      expect(page).to have_current_path(admin_users_path)
    end

    scenario 'non-admin cannot access admin dashboard' do
      login_as regular_user
      visit admin_root_path

      expect(page).to have_current_path(root_path)
      expect(page).to have_text('Access denied')
    end

    scenario 'non-admin cannot access admin users page' do
      login_as regular_user
      visit admin_users_path

      expect(page).to have_current_path(root_path)
      expect(page).to have_text('Access denied')
    end

    scenario 'unauthenticated user is redirected to sign in' do
      visit admin_root_path

      expect(page).to have_current_path(new_user_session_path)
    end
  end

  feature "Admin Link in Main Layout" do
    scenario 'admin sees admin panel link' do
      login_as admin
      visit root_path

      expect(page).to have_link('Admin', href: admin_root_path)
    end

    scenario 'non-admin does not see admin panel link' do
      login_as regular_user
      visit root_path

      expect(page).not_to have_link('Admin')
    end
  end

  feature "Dashboard Statistics" do
    before do
      FactoryBot.create_list(:user, 3)
      FactoryBot.create(:user, :banned)
      user_with_estimations = FactoryBot.create(:user_with_nonempty_estimations, n: 2)
      FactoryBot.create(:estimation_share, estimation: user_with_estimations.estimations.first)
    end

    scenario 'dashboard displays user statistics' do
      login_as admin
      visit admin_root_path

      expect(page).to have_text('Total Users')
      expect(page).to have_text('Banned')
    end

    scenario 'dashboard displays estimation statistics' do
      login_as admin
      visit admin_root_path

      expect(page).to have_text('Total')
      expect(page).to have_text('Total Items')
      expect(page).to have_text('Total Shares')
    end

    scenario 'dashboard displays activity statistics' do
      login_as admin
      visit admin_root_path

      expect(page).to have_text('Active (7 days)')
      expect(page).to have_text('Active (30 days)')
    end
  end

  feature "Admin Navigation" do
    scenario 'admin can navigate between dashboard and users' do
      login_as admin
      visit admin_root_path

      click_link 'Users'
      expect(page).to have_current_path(admin_users_path)

      click_link 'Dashboard'
      expect(page).to have_current_path(admin_root_path)
    end

    scenario 'admin can navigate back to main app' do
      login_as admin
      visit admin_root_path

      click_link 'Back to App'
      expect(page).to have_current_path(root_path)
    end
  end

  feature "Users Management" do
    let!(:target_user) { FactoryBot.create(:user, email: 'target@example.com', sign_in_count: 10) }
    let!(:banned_user) { FactoryBot.create(:user, :banned, email: 'banned@example.com') }

    scenario 'admin sees list of all users' do
      login_as admin
      visit admin_users_path

      expect(page).to have_text('admin@example.com')
      expect(page).to have_text('target@example.com')
      expect(page).to have_text('banned@example.com')
    end

    scenario 'admin sees user details' do
      login_as admin
      visit admin_users_path

      within('tr', text: 'target@example.com') do
        expect(page).to have_text('10') # sign_in_count
        expect(page).to have_selector('.tag.is-success', text: 'Active')
      end
    end

    scenario 'admin sees banned status for banned users' do
      login_as admin
      visit admin_users_path

      within('tr', text: 'banned@example.com') do
        expect(page).to have_selector('.tag.is-danger', text: /Banned/)
      end
    end

    scenario 'admin sees admin badge for admin users' do
      login_as admin
      visit admin_users_path

      # Find the row where admin@example.com appears in the first cell (email column)
      expect(page).to have_selector('tr td:first-child', text: 'admin@example.com')
      expect(page).to have_selector('.tag.is-info', text: 'Admin')
    end
  end
end
