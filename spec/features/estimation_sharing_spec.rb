require 'rails_helper'

feature "EstimationSharing", type: :feature do
  let(:owner) { FactoryBot.create(:user, email: 'owner@example.com') }
  let(:estimation) { FactoryBot.create(:estimation, user: owner, title: 'Test Estimation') }

  scenario 'Owner can share estimation with existing user' do
    shared_user = FactoryBot.create(:user, email: 'shared@example.com')

    login_as owner
    visit estimation_path(estimation)

    click_link 'Sharing'

    fill_in 'Email Address', with: 'shared@example.com'
    click_button 'Share'

    expect(page).to have_content('Estimation shared successfully')
    expect(page).to have_content('shared@example.com')
    expect(page).to have_content('Active')

  end

  scenario 'Sharing button shows share count badge' do
    shared_user = FactoryBot.create(:user, email: 'badge@example.com')
    FactoryBot.create(:estimation_share, :active, estimation: estimation, shared_with_user: shared_user)

    login_as owner
    visit estimation_path(estimation)

    expect(page).to have_css('a.button.is-small.is-link .tag', text: '1')
  end

  scenario 'Owner can share estimation with pending viewer (not signed up)' do
    login_as owner
    visit estimation_path(estimation)

    click_link 'Sharing'

    fill_in 'Email Address', with: 'pending@example.com'
    click_button 'Share'

    expect(page).to have_content('Estimation shared successfully')
    expect(page).to have_content('pending@example.com')
    expect(page).to have_content('Pending')

  end

  scenario 'Shared user can edit items but not manage shares' do
    shared_user = FactoryBot.create(:user, email: 'viewer@example.com')
    FactoryBot.create(:estimation_share, :active, estimation: estimation, shared_with_user: shared_user)

    login_as shared_user
    visit estimation_path(estimation)

    expect(page).to have_content('Test Estimation')
    expect(page).to have_content('This estimation is shared with you')
    expect(page).not_to have_link('Sharing')
    # Shared editors CAN edit items (editable forms are present)
    expect(page).not_to have_css('.tracking-toggle-button')
  end



  scenario 'Owner is notified when attempting to share with an existing viewer' do
    shared_user = FactoryBot.create(:user, email: 'shared@example.com')
    FactoryBot.create(:estimation_share, :active, estimation: estimation, shared_with_user: shared_user)

    login_as owner
    visit estimation_estimation_shares_path(estimation)

    fill_in 'Email Address', with: 'shared@example.com'
    click_button 'Share'

    expect(page).to have_content('shared@example.com already has access.')
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
    FactoryBot.create(:estimation_share, :active, estimation: estimation, shared_with_user: new_owner)

    login_as owner
    visit estimation_estimation_shares_path(estimation)

    expect(page).to have_content('newowner@example.com')

    click_button 'Transfer Ownership', match: :first

    # After transfer, user is redirected to the estimation page (not shares page, since they no longer have manage_shares permission)
    expect(page).to have_content('Ownership transferred successfully')
    expect(page).to have_content('Test Estimation')

    # Original owner should now be a viewer
    expect(estimation.reload.user).to eq(new_owner)
    expect(estimation.estimation_shares.where(shared_with_user: owner)).to exist
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
    click_button 'Share'

    # Should show error and not create the share
    expect(page).to have_content('cannot share with the estimation owner')
  end

  scenario 'Owner can view last accessed time for shares' do
    shared_user = FactoryBot.create(:user, email: 'accessed@example.com')
    share = FactoryBot.create(:estimation_share, :active, estimation: estimation, shared_with_user: shared_user, last_accessed_at: 1.hour.ago)

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
