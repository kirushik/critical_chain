# == Schema Information
#
# Table name: estimation_items
#
#  id            :integer          not null, primary key
#  value         :integer
#  title         :string
#  estimation_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  fixed         :boolean          default(FALSE), not null
#  quantity      :integer          default(1), not null
#  actual_value  :float
#
# Indexes
#
#  index_estimation_items_on_estimation_id  (estimation_id)
#

require 'rails_helper'

RSpec.describe EstimationItem, :type => :model do
  subject { FactoryGirl.build(:estimation_item) }

  def should_not_accept_value value
    subject.value = value
    expect(subject).not_to be_valid
  end

  def should_accept_value value
    subject.value = value
    expect(subject).to be_valid
  end

  it 'should validate presence of value' do
    should_not_accept_value nil
    should_accept_value 1
  end

  it 'should accept non-negative integers only' do
    should_not_accept_value -1
    should_accept_value 0
  end

  it 'should be not-fixed by default' do
    expect(EstimationItem.new.fixed?).to eq false
  end
end
