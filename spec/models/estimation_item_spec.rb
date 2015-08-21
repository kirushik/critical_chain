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

  def it_should_not_accept field, value
    subject.update_attribute field, value
    expect(subject).not_to be_valid
  end

  def it_should_accept field, value
    subject.update_attribute field, value
    expect(subject).to be_valid
  end

  describe '#value' do
    it 'should validate presence' do
      it_should_not_accept :value, nil
      it_should_accept :value, 1
    end

    it 'should accept non-negative integers only' do
      it_should_not_accept :value, -1
      it_should_accept :value, 0
    end
  end

  describe '#title' do
    it 'should validate presence' do
      it_should_not_accept :title, nil
      it_should_not_accept :title, ''
      it_should_accept :title, 'q'
    end
  end

  it 'should be not-fixed by default' do
    expect(EstimationItem.new.fixed?).to eq false
  end
end
