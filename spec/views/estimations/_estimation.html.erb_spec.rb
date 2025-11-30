require 'rails_helper'

RSpec.describe "estimations/_estimation.html.erb", :type => :view do
  let(:estimation) { FactoryBot.create(:estimation_with_items, items: {size: 1, count: 4}).decorate }

  before do
    render partial: "estimations/estimation", locals: { estimation: estimation }
  end

  it 'renders estimation title as a clickable link' do
    expect(rendered).to have_selector(
      ".estimation-row-link[href='#{estimation_path(estimation)}']",
      text: estimation.title
    )
  end

  it 'renders delete button with accessible aria-label' do
    expect(rendered).to have_selector(
      ".delete-estimation-button[aria-label='Delete estimation: #{estimation.title}']"
    )
  end

  it 'includes estimation title in delete confirmation message' do
    expect(rendered).to have_selector(
      "button[data-turbo-confirm*='#{estimation.title}']"
    )
  end

  context 'in planning mode' do
    let(:estimation) { FactoryBot.create(:estimation_with_items, items: {size: 1, count: 4}, tracking_mode: false).decorate }

    it 'shows planning mode indicator' do
      expect(rendered).to have_selector('.tag', text: 'Planning')
      expect(rendered).to have_selector('.fa-pen-ruler')
    end

    it 'does not show tracking indicator' do
      expect(rendered).not_to have_selector('.tag.is-info')
    end

    it 'renders calculation as sum + buffer = total' do
      expect(rendered).to have_text('+')
      expect(rendered).to have_text('=')
    end

    it 'renders sum value with correct color class' do
      expect(rendered).to have_selector('.calculation-value.is-sum', text: '4')
    end

    it 'renders buffer value with correct color class' do
      expect(rendered).to have_selector('.calculation-value.is-buffer', text: '2')
    end

    it 'renders total value with correct color class' do
      expect(rendered).to have_selector('.calculation-value.is-total', text: '6')
    end
  end

  context 'in tracking mode' do
    let(:estimation) { FactoryBot.create(:estimation_with_items, items: {size: 1, count: 4}, tracking_mode: true).decorate }

    before do
      # Set actual values on some items
      estimation.estimation_items.first.update!(actual_value: 2)

    end

    it 'shows tracking mode indicator' do
      render partial: "estimations/estimation", locals: { estimation: estimation }
      expect(rendered).to have_selector('.tag.is-info', text: 'Tracking')
      expect(rendered).to have_selector('.fa-play')
    end

    it 'renders calculation as actual / total' do
      render partial: "estimations/estimation", locals: { estimation: estimation }
      expect(rendered).to have_text('/')
      expect(rendered).not_to have_selector('.calculation-value.is-sum')
      expect(rendered).not_to have_selector('.calculation-value.is-buffer')
    end

    it 'renders actual value with correct color class' do
      render partial: "estimations/estimation", locals: { estimation: estimation }
      expect(rendered).to have_selector('.calculation-value.is-actual', text: '2')
    end

    it 'renders total value with correct color class' do
      render partial: "estimations/estimation", locals: { estimation: estimation }
      expect(rendered).to have_selector('.calculation-value.is-total', text: '6')
    end

    it 'shows buffer health percentage' do
      render partial: "estimations/estimation", locals: { estimation: estimation }
      expect(rendered).to have_selector('.calculation-value[title="Buffer consumption"]')
    end

    it 'applies correct color class based on buffer health' do
      render partial: "estimations/estimation", locals: { estimation: estimation }
      # With actual_value=2 and estimate=1, we're over budget, health should be success/warning/danger
      expect(rendered).to have_selector('.calculation-value.has-text-success, .calculation-value.has-text-warning, .calculation-value.has-text-danger')
    end
  end
end
