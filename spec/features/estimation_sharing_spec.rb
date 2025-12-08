require 'rails_helper'

feature "EstimationSharing", type: :feature do
  let(:owner) { FactoryBot.create(:user, email: 'owner@example.com') }
  let(:estimation) { FactoryBot.create(:estimation, user: owner, title: 'Test Estimation') }

  scenario 'Owner can share estimation with existing user' do
    shared_user = FactoryBot.create(:user, email: 'shared@example.com')
    
    login_as owner
    visit estimation_path(estimation)
    
    click_link 'Manage Shares'
    
    fill_in 'Email Address', with: 'shared@example.com'
    select 'Viewer (read-only)', from: 'Access Level'
    click_button 'Share'
    
    expect(page).to have_content('Estimation shared successfully')
    expect(page).to have_content('shared@example.com')
    expect(page).to have_content('Active')
    expect(page).to have_content('Viewer')
  end

  scenario 'Owner can share estimation with pending user (not signed up)' do
    login_as owner
    visit estimation_path(estimation)
    
    click_link 'Manage Shares'
    
    fill_in 'Email Address', with: 'pending@example.com'
    select 'Owner (can edit)', from: 'Access Level'
    click_button 'Share'
    
    expect(page).to have_content('Estimation shared successfully')
    expect(page).to have_content('pending@example.com')
    expect(page).to have_content('Pending')
    expect(page).to have_content('Owner')
  end

  scenario 'Shared user can view but not share estimation' do
    shared_user = FactoryBot.create(:user, email: 'viewer@example.com')
    FactoryBot.create(:estimation_share, :active, :viewer, estimation: estimation, shared_with_user: shared_user)
    
    login_as shared_user
    visit estimation_path(estimation)
    
    expect(page).to have_content('Test Estimation')
    expect(page).to have_content('This estimation is shared with you')
    expect(page).not_to have_link('Manage Shares')
  end

  scenario 'Shared owner can edit estimation' do
    shared_owner = FactoryBot.create(:user, email: 'editor@example.com')
    FactoryBot.create(:estimation_share, :active, :owner, estimation: estimation, shared_with_user: shared_owner)
    
    login_as shared_owner
    visit estimation_path(estimation)
    
    expect(page).to have_content('Test Estimation')
    # Shared owners can see the estimation but not manage shares (only original owner can)
    expect(page).not_to have_link('Manage Shares')
  end

  scenario 'Owner can revoke access' do
    shared_user = FactoryBot.create(:user, email: 'revoked@example.com')
    FactoryBot.create(:estimation_share, :active, estimation: estimation, shared_with_user: shared_user)
    
    login_as owner
    visit estimation_estimation_shares_path(estimation)
    
    expect(page).to have_content('revoked@example.com')
    
    click_button 'Revoke', match: :first
    
    expect(page).to have_content('Access revoked successfully')
    expect(page).not_to have_content('revoked@example.com')
  end

  scenario 'Owner can transfer ownership' do
    new_owner = FactoryBot.create(:user, email: 'newowner@example.com')
    FactoryBot.create(:estimation_share, :active, :owner, estimation: estimation, shared_with_user: new_owner)
    
    login_as owner
    visit estimation_estimation_shares_path(estimation)
    
    expect(page).to have_content('newowner@example.com')
    
    click_button 'Transfer Ownership', match: :first
    
    expect(page).to have_content('Ownership transferred successfully')
    
    # Original owner should now be a viewer
    expect(estimation.reload.user).to eq(new_owner)
    expect(estimation.estimation_shares.where(shared_with_user: owner, role: 'viewer')).to exist
  end

  scenario 'Pending share becomes active when user signs up' do
    FactoryBot.create(:estimation_share, :pending, estimation: estimation, shared_with_email: 'newuser@example.com')
    
    # Simulate user signing up with the pending email
    new_user = FactoryBot.create(:user, email: 'newuser@example.com')
    
    share = estimation.estimation_shares.first
    expect(share.reload.shared_with_user).to eq(new_user)
    expect(share.active?).to be true
    
    login_as new_user
    visit estimations_path
    
    # User should see the shared estimation
    expect(page).to have_content('Test Estimation')
  end

  scenario 'Non-owner cannot access estimation' do
    other_user = FactoryBot.create(:user)
    
    login_as other_user
    visit estimation_path(estimation)
    
    expect(page.status_code).to be(403)
  end

  scenario 'Owner cannot share with themselves' do
    login_as owner
    visit estimation_estimation_shares_path(estimation)
    
    fill_in 'Email Address', with: owner.email
    select 'Viewer (read-only)', from: 'Access Level'
    click_button 'Share'
    
    # Should show error and not create the share
    expect(page).to have_content('cannot share with the estimation owner')
  end

  scenario 'Owner can view last accessed time for shares' do
    shared_user = FactoryBot.create(:user, email: 'accessed@example.com')
    share = FactoryBot.create(:estimation_share, :active, :accessed, estimation: estimation, shared_with_user: shared_user)
    
    login_as owner
    visit estimation_estimation_shares_path(estimation)
    
    expect(page).to have_content('accessed@example.com')
    expect(page).to have_content('ago')
  end

  scenario 'Last accessed time is updated when shared user views estimation' do
    shared_user = FactoryBot.create(:user, email: 'viewer@example.com')
    share = FactoryBot.create(:estimation_share, :active, estimation: estimation, shared_with_user: shared_user)
    
    expect(share.last_accessed_at).to be_nil
    
    login_as shared_user
    visit estimation_path(estimation)
    
    expect(share.reload.last_accessed_at).not_to be_nil
  end
end
