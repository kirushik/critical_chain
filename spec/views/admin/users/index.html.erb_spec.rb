require 'rails_helper'

RSpec.describe "admin/users/index.html.erb", type: :view do
  before do
    allow(ENV).to receive(:fetch).with('ADMIN_EMAILS', '').and_return('admin@example.com')
  end

  context 'with users' do
    let(:admin_user) { FactoryBot.create(:user, email: 'admin@example.com', sign_in_count: 50, last_sign_in_at: 1.day.ago) }
    let(:regular_user) { FactoryBot.create(:user, email: 'user@example.com', sign_in_count: 10, last_sign_in_at: 2.days.ago) }
    let(:banned_user) { FactoryBot.create(:user, :banned, email: 'banned@example.com', sign_in_count: 5) }

    before do
      assign(:users, [admin_user, regular_user, banned_user])
      render
    end

    it 'displays the page title' do
      expect(rendered).to have_selector('h1.title', text: 'Users')
    end

    it 'displays the subtitle' do
      expect(rendered).to have_selector('h2.subtitle', text: 'Manage registered users')
    end

    it 'renders a table with headers' do
      expect(rendered).to have_selector('table')
      expect(rendered).to have_selector('th', text: 'Email')
      expect(rendered).to have_selector('th', text: 'Sign-ins')
      expect(rendered).to have_selector('th', text: 'Last Sign-in')
      expect(rendered).to have_selector('th', text: 'Registered')
      expect(rendered).to have_selector('th', text: 'Status')
      expect(rendered).to have_selector('th', text: 'Actions')
    end

    it 'displays all users' do
      expect(rendered).to have_text('admin@example.com')
      expect(rendered).to have_text('user@example.com')
      expect(rendered).to have_text('banned@example.com')
    end

    it 'displays sign-in counts' do
      expect(rendered).to have_text('50')
      expect(rendered).to have_text('10')
      expect(rendered).to have_text('5')
    end

    it 'shows admin badge for admin users' do
      expect(rendered).to have_selector('.tag.is-info', text: 'Admin')
    end

    it 'shows active status for non-banned users' do
      expect(rendered).to have_selector('.tag.is-success', text: 'Active', count: 2)
    end

    it 'shows banned status for banned users' do
      expect(rendered).to have_selector('.tag.is-danger', text: /Banned/)
    end

    it 'shows ban button for regular non-banned users' do
      expect(rendered).to have_button('Ban')
    end

    it 'shows unban button for banned users' do
      expect(rendered).to have_button('Unban')
    end

    it 'highlights banned user rows' do
      expect(rendered).to have_selector('tr.has-background-danger-light')
    end
  end

  context 'with empty users list' do
    before do
      assign(:users, [])
      render
    end

    it 'renders an empty table' do
      expect(rendered).to have_selector('table')
      expect(rendered).to have_selector('tbody')
    end
  end
end
