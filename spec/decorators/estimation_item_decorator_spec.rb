require 'rails_helper'

describe EstimationItemDecorator do
  let(:estimation) {FactoryGirl.create(:estimation_with_items)}
  let(:value) {estimation.estimation_items.first.title}
  subject {estimation.estimation_items.first.decorate.editable :title}

  it 'renders editable as an HTML string' do
    expect(subject).to be_a String
  end

  it 'assigns "editable" class to the rendered <input> tag' do
    expect(Nokogiri::HTML::fragment(subject).css('input.editable')).not_to be_empty
  end

  it 'puts field value into <input> values' do
    expect(Nokogiri::HTML::fragment(subject).css("input[value='#{value}']")).not_to be_empty
  end

  it 'puts object name into `data-object` attribute' do
    expect(Nokogiri::HTML::fragment(subject).at('input.editable')['data-object']).
      to eq "estimation_item"
  end

  it 'puts path to estimation_item into `data-path` attribute' do
    expect(Nokogiri::HTML::fragment(subject).at('input.editable')['data-path']).
      to eq "/estimations/1/estimation_items/1"
  end

  it 'puts field name into `data-field` attribute and into class' do
    expect(Nokogiri::HTML::fragment(subject).at('input.editable')['data-field']).
      to eq 'title'
    expect(Nokogiri::HTML::fragment(subject).css('input.title')).not_to be_empty
  end
end
