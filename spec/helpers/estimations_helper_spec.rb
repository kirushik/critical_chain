require 'rails_helper'

describe EstimationsHelper do
  describe '#rounded_estimate' do
    it 'rounds large numbers as integers' do
      estimation = FactoryBot.create(:estimation_with_items, items: { count: 4, size: 100 })

      expect(helper.rounded_estimate(estimation.sum)).to eq('400')
      expect(helper.rounded_estimate(estimation.buffer)).to eq('200')
      expect(helper.rounded_estimate(estimation.total)).to eq('600')
    end

    it 'rounds one-digit values to .XX' do
      estimation = FactoryBot.create(:estimation_with_items, items: { count: 2, size: 1 })

      expect(helper.rounded_estimate(estimation.sum)).to eq('2')
      expect(helper.rounded_estimate(estimation.buffer)).to eq('1.41')
      expect(helper.rounded_estimate(estimation.total)).to eq('3.41')
    end

    it 'works with empty estimations' do
      estimation = FactoryBot.create(:estimation)

      expect(helper.rounded_estimate(estimation.sum)).to eq('0')
      expect(helper.rounded_estimate(estimation.buffer)).to eq('0')
      expect(helper.rounded_estimate(estimation.total)).to eq('0')
    end

    it 'casts round floats to integers' do
      estimation = FactoryBot.create(:estimation_with_items, items: { count: 1, size: 1 })

      expect(helper.rounded_estimate(estimation.sum)).to eq('1')
      expect(helper.rounded_estimate(estimation.buffer)).to eq('1')
      expect(helper.rounded_estimate(estimation.total)).to eq('2')
    end

    it 'shows 0 for a missing value' do
      expect(helper.rounded_estimate(nil)).to eq('0')
    end
  end

  describe '#estimation_items_partial' do
    it 'returns correct partial for estimation mode' do
      estimation = FactoryBot.create(:estimation)
      expect(helper.estimation_items_partial(estimation)).to eq('estimation_items/estimation_item')
    end

    it 'returns correct for tracking mode' do
      estimation = FactoryBot.create(:estimation, tracking_mode: true)
      expect(helper.estimation_items_partial(estimation)).to eq('estimation_items/estimation_item_trackable')
    end
  end

  describe '#buffer_health_percentage' do
    it 'outputs percentage' do
      estimation = FactoryBot.create(:estimation)
      FactoryBot.create :estimation_item, estimation: estimation, value: 1, actual_value: 2

      expect(helper.buffer_health_percentage(estimation)).to eq '100%'
    end
  end

  # TODO: Make smarter function here. Buffer health 1.1 is norm at the beginning of the project and critically wrong at the end
  describe '#buffer_health_class' do
    let(:estimation) { FactoryBot.build(:estimation) }

    def class_for(health)
      allow(estimation).to receive(:buffer_health).and_return(health)
      helper.buffer_health_class(estimation)
    end

    it 'is has-text-success when health is less than 0.8' do
      expect(class_for(0.0)).to eq 'has-text-success'
      expect(class_for(0.1)).to eq 'has-text-success'
      expect(class_for(0.7)).to eq 'has-text-success'
      expect(class_for(0.8)).not_to eq 'has-text-success'
    end

    it 'is has-text-warning when health belongs to 0.8...1.0' do
      expect(class_for(0.8)).to eq 'has-text-warning'
      expect(class_for(0.9)).to eq 'has-text-warning'
      expect(class_for(1.0)).not_to eq 'has-text-warning'
    end

    it 'is has-text-danger when health is above 1.0' do
      expect(class_for(1)).to eq 'has-text-danger'
      expect(class_for(2)).to eq 'has-text-danger'
      expect(class_for(100)).to eq 'has-text-danger'
    end
  end
end
