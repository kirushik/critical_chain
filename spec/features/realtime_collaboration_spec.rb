require 'rails_helper'

# Two people with the same estimation open: changes reach the other's page
# over Action Cable (Turbo Stream broadcasts from the models), and keep
# reaching it after the first one.
feature 'Realtime collaboration', :playwright do
  let(:owner) { create(:user, email: 'owner@example.com') }
  let(:collaborator) { create(:user, email: 'collaborator@example.com') }
  let(:estimation) { create(:estimation, user: owner, title: 'Kitchen remodel') }
  let!(:item) { create(:estimation_item, estimation: estimation, title: 'Cabinets', value: 3) }
  # In a second browser context: its own cookies, so its own signed-in user.
  let(:collaborator_page) { browser.new_context(viewport: { width: 1400, height: 1400 }).new_page }

  # Broadcasts go out from jobs (broadcast_*_later_to), which the test
  # adapter would only enqueue.
  around do |example|
    adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :inline
    example.run
  ensure
    ActiveJob::Base.queue_adapter = adapter
  end

  before do
    create(:estimation_share, :active, estimation: estimation, shared_with_user: collaborator)

    login_as owner
    visit estimation_path(estimation)
    wait_until_subscribed(page)

    login_as collaborator
    collaborator_page.goto(app_url(estimation_path(estimation)))
    wait_until_subscribed(collaborator_page)
  end

  after { collaborator_page.context.close }

  # The server spec/support/playwright.rb boots for this example.
  def app_url(path)
    server = instance_variable_get(:@capybara_server)
    "http://#{server.host}:#{server.port}#{path}"
  end

  def wait_until_subscribed(on_page)
    on_page.wait_for_selector('turbo-cable-stream-source[connected]', state: 'attached')
  end

  def wait_for_text(on_page, selector, text)
    on_page.wait_for_function(<<~JS, arg: [selector, text], timeout: 5000)
      ([selector, text]) => document.querySelector(selector)?.textContent.trim() === text
    JS
  end

  scenario 'totals keep updating for the other viewer, edit after edit' do
    expect(collaborator_page.text_content('#total').strip).to eq('6')

    item.update!(value: 5)
    wait_for_text(collaborator_page, '#total', '10')

    item.update!(value: 7)
    wait_for_text(collaborator_page, '#total', '14')
    wait_for_text(collaborator_page, '#sum', '7')
    wait_for_text(collaborator_page, '#buffer', '7')
  end

  scenario 'a rename updates the title and leaves each header as it was' do
    estimation.update!(title: '<b>Kitchen</b> & bath')

    # The collaborator sees the new title, as text, with their own notice
    wait_for_text(collaborator_page, '#estimation_title .estimation-title-text', '<b>Kitchen</b> & bath')
    expect(collaborator_page.locator('#estimation_title b').count).to eq(0)
    expect(collaborator_page.text_content('#estimation_title')).to include('shared with you by owner@example.com')

    # The owner's header keeps the editable title and the Sharing button
    wait_for_text(page, '#estimation_title .editable-display', '<b>Kitchen</b> & bath')
    expect(page.locator('#estimation_title a', hasText: 'Sharing').count).to eq(1)
    expect(page.text_content('#estimation_title')).not_to include('shared with you')
  end

  scenario 'the owner renaming inline keeps their Sharing button' do
    page.get_by_title('Click to edit').filter(hasText: 'Kitchen remodel').click
    page.locator("h1 input[type='text']").fill('Bathroom')
    page.get_by_role('button', name: 'Save').click

    wait_for_text(page, '#estimation_title .editable-display', 'Bathroom')
    expect(page.locator('#estimation_title a', hasText: 'Sharing').count).to eq(1)
    wait_for_text(collaborator_page, '#estimation_title .estimation-title-text', 'Bathroom')
  end
end
