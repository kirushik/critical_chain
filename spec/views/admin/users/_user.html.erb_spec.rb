require 'rails_helper'

RSpec.describe "admin/users/_user.html.erb", type: :view do
  before do
    allow(ENV).to receive(:fetch).with('ADMIN_EMAILS', '').and_return('admin@example.com')
  end

  context 'for a regular active user' do
    let(:user) { FactoryBot.create(:user, email: 'regular@example.com', sign_in_count: 15, last_sign_in_at: 3.hours.ago, created_at: 10.days.ago) }

    before do
      render partial: 'admin/users/user', locals: { user: user }
    end

    it 'displays user email' do
      expect(rendered).to have_text('regular@example.com')
    end

    it 'displays sign-in count' do
      expect(rendered).to have_text('15')
    end

    it 'displays last sign-in time in words' do
      expect(rendered).to have_text(/hours ago/)
    end

    it 'displays registration date' do
      expect(rendered).to have_text(user.created_at.strftime('%Y-%m-%d'))
    end

    it 'shows active status tag' do
      expect(rendered).to have_selector('.tag.is-success', text: 'Active')
    end

    it 'does not show admin badge' do
      expect(rendered).not_to have_selector('.tag.is-info', text: 'Admin')
    end

    it 'shows ban button' do
      expect(rendered).to have_selector('button', text: 'Ban')
    end

    it 'does not show unban button' do
      expect(rendered).not_to have_selector('button', text: 'Unban')
    end

    it 'does not have danger background' do
      expect(rendered).not_to have_selector('tr.has-background-danger-light')
    end

    it 'has confirmation dialog on ban button' do
      expect(rendered).to have_selector('[data-turbo-confirm]')
    end
  end

  context 'for a banned user' do
    let(:user) { FactoryBot.create(:user, :banned, email: 'banned@example.com', banned_by_email: 'admin@example.com') }

    before do
      render partial: 'admin/users/user', locals: { user: user }
    end

    it 'shows banned status tag' do
      expect(rendered).to have_selector('.tag.is-danger', text: /Banned/)
    end

    it 'shows who banned the user' do
      expect(rendered).to have_text('by admin@example.com')
    end

    it 'shows unban button' do
      expect(rendered).to have_selector('button', text: 'Unban')
    end

    it 'does not show ban button' do
      expect(rendered).not_to have_selector('button', text: 'Ban')
    end

    it 'has danger background' do
      expect(rendered).to have_selector('tr.has-background-danger-light')
    end
  end

  context 'for an admin user' do
    let(:user) { FactoryBot.create(:user, email: 'admin@example.com') }

    before do
      render partial: 'admin/users/user', locals: { user: user }
    end

    it 'shows admin badge' do
      expect(rendered).to have_selector('.tag.is-info', text: 'Admin')
    end

    it 'does not show ban button' do
      expect(rendered).not_to have_selector('button', text: 'Ban')
    end

    it 'does not show unban button' do
      expect(rendered).not_to have_selector('button', text: 'Unban')
    end
  end

  context 'for a user who never signed in' do
    let(:user) { FactoryBot.create(:user, last_sign_in_at: nil) }

    before do
      render partial: 'admin/users/user', locals: { user: user }
    end

    it 'shows Never for last sign-in' do
      expect(rendered).to have_text('Never')
    end
  end
end
