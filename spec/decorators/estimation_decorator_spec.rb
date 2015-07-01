require 'rails_helper'

describe EstimationDecorator do
  it "rounds large numbers as integers" do
    estimation = FactoryGirl.create(:estimation_with_items, items: {count: 4, size: 100}).decorate

    expect(estimation.buffer).to eq("200")
    expect(estimation.total).to eq("600")
  end

  it "rounds one-digit values to .XX" do
    estimation = FactoryGirl.create(:estimation_with_items, items: {count: 2, size: 1}).decorate

    expect(estimation.buffer).to eq("1.41")
    expect(estimation.total).to eq("3.41")    
  end

  it 'works with empty estimations' do
    estimation = FactoryGirl.create(:estimation).decorate

    expect(estimation.buffer).to eq("0")
    expect(estimation.total).to eq("0")
  end

  it "casts round floats to integers" do
    estimation = FactoryGirl.create(:estimation_with_items, items: {count: 1, size: 1}).decorate

    expect(estimation.buffer).to eq("1")
    expect(estimation.total).to eq("2") 
  end

  describe '#items_partial_name' do
    it 'returns correct partial for estimation mode' do
      estimation = FactoryGirl.create(:estimation).decorate
      expect(estimation.items_partial_name).to eq("estimation_items/estimation_item") 
    end

    it 'returns correct for tracking mode' do
      estimation = FactoryGirl.create(:estimation, tracking_mode: true).decorate
      expect(estimation.items_partial_name).to eq("estimation_items/estimation_item_trackable") 
    end
  end

  describe '#actual_sum' do
    it 'returns correct partial for estimation mode' do
      estimation = FactoryGirl.create(:estimation)
      FactoryGirl.create :estimation_item, estimation: estimation, actual_value: 1
      FactoryGirl.create :estimation_item, estimation: estimation
      
      expect(estimation.decorate.actual_sum).to eq(1.0) 
    end
  end
end
