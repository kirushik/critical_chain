require 'rails_helper'

describe EstimationItemDecorator do
  let(:estimation) { FactoryGirl.create(:estimation_with_items) }
  let(:estimation_item) { estimation.estimation_items.first }

  subject { estimation_item.decorate.editable :title }

  let(:value) { estimation_item.title }
  let(:field_id) { "estimation_item_#{estimation_item.id}_title" }

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

  it 'assigns right id to the element' do
    expect(Nokogiri::HTML::fragment(subject).css("input\##{field_id}")).not_to be_empty
  end
end
