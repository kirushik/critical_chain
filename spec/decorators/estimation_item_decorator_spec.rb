require 'rails_helper'

describe EstimationItemDecorator do
  let(:estimation) {FactoryBot.create(:estimation_with_items)}
  subject {estimation.estimation_items.first.decorate}

  it 'renders proper editable <span>' do
    expect(subject.editable :title).to be_a String
  end
end
