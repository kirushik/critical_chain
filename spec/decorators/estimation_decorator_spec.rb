require 'rails_helper'

describe EstimationDecorator do
  it "rounds large numbers as integers" do
    estimation = FactoryBot.create(:estimation_with_items, items: {count: 4, size: 100}).decorate

    expect(estimation.sum).to eq("400")
    expect(estimation.buffer).to eq("200")
    expect(estimation.total).to eq("600")
  end

  it "rounds one-digit values to .XX" do
    estimation = FactoryBot.create(:estimation_with_items, items: {count: 2, size: 1}).decorate

    expect(estimation.sum).to eq("2")
    expect(estimation.buffer).to eq("1.41")
    expect(estimation.total).to eq("3.41")
  end

  it 'works with empty estimations' do
    estimation = FactoryBot.create(:estimation).decorate

    expect(estimation.sum).to eq("0")
    expect(estimation.buffer).to eq("0")
    expect(estimation.total).to eq("0")
  end

  it "casts round floats to integers" do
    estimation = FactoryBot.create(:estimation_with_items, items: {count: 1, size: 1}).decorate

    expect(estimation.sum).to eq("1")
    expect(estimation.buffer).to eq("1")
    expect(estimation.total).to eq("2")
  end

  describe '#items_partial_name' do
    it 'returns correct partial for estimation mode' do
      estimation = FactoryBot.create(:estimation).decorate
      expect(estimation.items_partial_name).to eq("estimation_items/estimation_item")
    end

    it 'returns correct for tracking mode' do
      estimation = FactoryBot.create(:estimation, tracking_mode: true).decorate
      expect(estimation.items_partial_name).to eq("estimation_items/estimation_item_trackable")
    end
  end

  describe '#actual_sum' do
    it 'returns correct partial for estimation mode' do
      estimation = FactoryBot.create(:estimation)
      FactoryBot.create :estimation_item, estimation: estimation, actual_value: 1
      FactoryBot.create :estimation_item, estimation: estimation

      expect(estimation.decorate.actual_sum).to eq(1.0)
    end
  end

  describe '#estimation_items' do
    it 'orders items by order field' do
      estimation = FactoryBot.create(:estimation)
      first_item = FactoryBot.create :estimation_item, estimation: estimation, created_at: 1.minute.ago
      second_item = FactoryBot.create :estimation_item, estimation: estimation, created_at: 1.hour.ago

      # Items should be ordered by the order field, not created_at
      # Since first_item is created first, it gets order=1.0, second_item gets order=2.0
      # They should be in the order they were created (by order value, not created_at)
      expect(estimation.decorate.estimation_items).to eq [first_item, second_item]
    end
  end

  describe '#buffer_health' do
    it 'outputs percentage' do
      estimation = FactoryBot.create(:estimation)
      new_item = FactoryBot.create :estimation_item, estimation: estimation, value: 1, actual_value: 2

      expect(estimation.decorate.buffer_health).to eq '100%'
    end
  end

  # TODO Make smarter function here. Buffer health 1.1 is norm at the beginning of the project and critically wrong at the and
  describe '#buffer_health_class' do
    subject { FactoryBot.create(:estimation) }

    it 'is has-text-success when health is less than 0.8' do
      expect(subject).to receive(:buffer_health).and_return(0.0)
      expect(subject.decorate.buffer_health_class).to eq 'has-text-success'

      expect(subject).to receive(:buffer_health).and_return(0.1)
      expect(subject.decorate.buffer_health_class).to eq 'has-text-success'

      expect(subject).to receive(:buffer_health).and_return(0.7)
      expect(subject.decorate.buffer_health_class).to eq 'has-text-success'

      expect(subject).to receive(:buffer_health).and_return(0.8)
      expect(subject.decorate.buffer_health_class).not_to eq 'has-text-success'
    end

    it 'is has-text-warning when health belongs to 0.8...1.0' do
      expect(subject).to receive(:buffer_health).and_return(0.8)
      expect(subject.decorate.buffer_health_class).to eq 'has-text-warning'

      expect(subject).to receive(:buffer_health).and_return(0.9)
      expect(subject.decorate.buffer_health_class).to eq 'has-text-warning'

      expect(subject).to receive(:buffer_health).and_return(1.0)
      expect(subject.decorate.buffer_health_class).not_to eq 'has-text-warning'
    end

    it 'is has-text-danger when health is above 1.0' do
      expect(subject).to receive(:buffer_health).and_return(1)
      expect(subject.decorate.buffer_health_class).to eq 'has-text-danger'

      expect(subject).to receive(:buffer_health).and_return(2)
      expect(subject.decorate.buffer_health_class).to eq 'has-text-danger'

      expect(subject).to receive(:buffer_health).and_return(100)
      expect(subject.decorate.buffer_health_class).to eq 'has-text-danger'
    end
  end
end
