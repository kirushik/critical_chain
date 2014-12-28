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
end
