require 'rails_helper'

RSpec.describe "estimations/index.html.erb", :type => :view do
  context 'with estimations' do
    let(:estimations) { (1..3).map { FactoryBot.create(:estimation).decorate } }

    before do
      assign(:estimations, estimations)
      render
    end

    it 'displays the page title' do
      expect(rendered).to have_selector('h1.title', text: 'My Estimations')
    end

    it 'contains the user\'s estimations' do
      expect(rendered).to have_selector('.estimation-row', count: 3)
      estimations.each do |estimation|
        expect(rendered).to have_text(estimation.title)
      end
    end

    it 'makes the entire title cell clickable with a link to the estimation' do
      estimations.each do |estimation|
        expect(rendered).to have_selector(
          ".estimation-row-link[href='#{estimation_path(estimation)}']",
          text: estimation.title
        )
      end
    end

    it 'shows calculation values for each estimation' do
      estimations.each do |estimation|
        within("##{dom_id(estimation)}") do
          expect(rendered).to have_selector('.calculation-value', minimum: 3)
        end
      end
    end

    it 'has an accessible delete button with aria-label' do
      estimations.each do |estimation|
        expect(rendered).to have_selector(
          ".delete-estimation-button[aria-label='Delete estimation: #{estimation.title}']"
        )
      end
    end

    it 'includes estimation title in delete confirmation' do
      estimations.each do |estimation|
        expect(rendered).to have_selector(
          "button[data-turbo-confirm*='#{estimation.title}']"
        )
      end
    end

    it 'does not show empty state' do
      expect(rendered).not_to have_selector('.empty-state')
    end
  end

  context 'mode indicator' do
    it 'shows planning mode indicator for estimations in planning mode' do
      estimation = FactoryBot.create(:estimation_with_items, items: {size: 1, count: 4}, tracking_mode: false).decorate
      assign(:estimations, [estimation])

      render

      within("##{dom_id(estimation)}") do
        expect(rendered).to have_selector('.tag', text: 'Planning')
        expect(rendered).to have_selector('.fa-pen-ruler')
      end
    end

    it 'shows sum + buffer = total for planning mode' do
      estimation = FactoryBot.create(:estimation_with_items, items: {size: 1, count: 4}, tracking_mode: false).decorate
      assign(:estimations, [estimation])

      render

      within("##{dom_id(estimation)}") do
        expect(rendered).to have_selector('.calculation-value.is-sum')
        expect(rendered).to have_selector('.calculation-value.is-buffer')
        expect(rendered).to have_selector('.calculation-value.is-total')
        expect(rendered).to have_text('+')
        expect(rendered).to have_text('=')
      end
    end

    it 'shows tracking mode indicator for estimations in tracking mode' do
      estimation = FactoryBot.create(:estimation_with_items, items: {size: 1, count: 4}, tracking_mode: true).decorate
      assign(:estimations, [estimation])

      render

      within("##{dom_id(estimation)}") do
        expect(rendered).to have_selector('.tag.is-info', text: 'Tracking')
        expect(rendered).to have_selector('.fa-play')
      end
    end

    it 'shows actual / total and buffer health for tracking mode' do
      estimation = FactoryBot.create(:estimation_with_items, items: {size: 1, count: 4}, tracking_mode: true)
      estimation.estimation_items.first.update!(actual_value: 2)
      assign(:estimations, [estimation.decorate])

      render

      within("##{dom_id(estimation)}") do
        expect(rendered).to have_selector('.calculation-value.is-actual')
        expect(rendered).to have_selector('.calculation-value.is-total')
        expect(rendered).to have_selector('.calculation-value[title="Buffer consumption"]')
        expect(rendered).to have_text('/')
        expect(rendered).not_to have_selector('.calculation-value.is-sum')
        expect(rendered).not_to have_selector('.calculation-value.is-buffer')
      end
    end
  end

  context 'without estimations' do
    before do
      assign(:estimations, [])
      render
    end

    it 'displays the page title' do
      expect(rendered).to have_selector('h1.title', text: 'My Estimations')
    end

    it 'shows empty state message' do
      expect(rendered).to have_selector('.empty-state')
      expect(rendered).to have_text("You don't have any estimations yet")
      expect(rendered).to have_text('Create your first estimation below')
    end

    it 'does not render the table' do
      expect(rendered).not_to have_selector('.estimations-table')
    end
  end

  context 'new estimation form' do
    before do
      assign(:estimations, [])
      render
    end

    it 'has an accessible input field' do
      expect(rendered).to have_selector('input[aria-label="New estimation title"]')
    end

    it 'has a create button' do
      expect(rendered).to have_selector('input[type="submit"][value="Create estimation"]')
    end
  end
end
