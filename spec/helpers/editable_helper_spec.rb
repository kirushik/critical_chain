require 'rails_helper'

describe EditableHelper do
  let(:estimation) { FactoryBot.create(:estimation_with_items) }
  let(:item) { estimation.estimation_items.first }

  # Devise's current_user comes from the controller; helper specs have none.
  before { helper.define_singleton_method(:current_user) { nil } }

  context 'when signed in as the estimation owner' do
    before { allow(helper).to receive(:current_user).and_return(estimation.user) }

    it 'renders an item field with an edit form saving to the item' do
      html = helper.editable_item_field(item, :title)
      expect(html).to include(%(action="#{estimation_estimation_item_path(estimation, item)}"))
      expect(html).not_to include('is-readonly')
    end

    it 'renders an estimation field with an edit form saving to the estimation' do
      html = helper.editable_estimation_field(estimation, :title)
      expect(html).to include(%(action="#{estimation_path(estimation)}"))
    end
  end

  it 'renders read-only fields for someone who cannot edit' do
    allow(helper).to receive(:current_user).and_return(FactoryBot.create(:user))
    expect(helper.editable_item_field(item, :title)).to include('is-readonly')
  end

  it 'renders read-only fields without a signed-in user (Turbo broadcasts)' do
    allow(helper).to receive(:current_user).and_raise(Devise::MissingWarden)
    expect(helper.editable_estimation_field(estimation, :title)).to include('is-readonly')
  end

  it 'lets an explicit can_edit win' do
    allow(helper).to receive(:current_user).and_return(nil)
    expect(helper.editable_item_field(item, :title, can_edit: true)).not_to include('is-readonly')
  end
end
