require 'rails_helper'

RSpec.describe "admin/dashboard/index.html.erb", type: :view do
  before do
    assign(:stats, {
      total_users: 100,
      users_last_7_days: 10,
      users_last_30_days: 25,
      total_estimations: 500,
      estimations_last_7_days: 50,
      estimations_last_30_days: 150,
      active_users_last_7_days: 30,
      active_users_last_30_days: 60,
      total_estimation_items: 2000,
      total_shares: 75,
      banned_users: 5
    })
    render
  end

  it 'displays the dashboard title' do
    expect(rendered).to have_selector('h1.title', text: 'Dashboard')
  end

  it 'displays the subtitle' do
    expect(rendered).to have_selector('h2.subtitle', text: 'System Overview')
  end

  describe 'users statistics box' do
    it 'displays total users count' do
      expect(rendered).to have_text('Total Users')
      expect(rendered).to have_text('100')
    end

    it 'displays new users in last 7 days' do
      expect(rendered).to have_text('New (7 days)')
      expect(rendered).to have_text('10')
    end

    it 'displays new users in last 30 days' do
      expect(rendered).to have_text('New (30 days)')
      expect(rendered).to have_text('25')
    end

    it 'displays banned users count' do
      expect(rendered).to have_text('Banned')
      expect(rendered).to have_text('5')
    end
  end

  describe 'activity statistics box' do
    it 'displays active users in last 7 days' do
      expect(rendered).to have_text('Active (7 days)')
      expect(rendered).to have_text('30')
    end

    it 'displays active users in last 30 days' do
      expect(rendered).to have_text('Active (30 days)')
      expect(rendered).to have_text('60')
    end
  end

  describe 'estimations statistics box' do
    it 'displays total estimations' do
      expect(rendered).to have_text('Total')
      expect(rendered).to have_text('500')
    end

    it 'displays estimation items count' do
      expect(rendered).to have_text('Total Items')
      expect(rendered).to have_text('2000')
    end

    it 'displays total shares count' do
      expect(rendered).to have_text('Total Shares')
      expect(rendered).to have_text('75')
    end
  end

  it 'renders three stat boxes' do
    expect(rendered).to have_selector('.box', count: 3)
  end

  it 'uses font awesome icons' do
    expect(rendered).to have_selector('.fa-users')
    expect(rendered).to have_selector('.fa-chart-bar')
    expect(rendered).to have_selector('.fa-calculator')
  end
end
