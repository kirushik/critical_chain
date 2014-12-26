# == Schema Information
#
# Table name: estimations
#
#  id         :integer          not null, primary key
#  title      :string
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_estimations_on_user_id  (user_id)
#

require 'rails_helper'

RSpec.describe Estimation, :type => :model do
  subject { FactoryGirl.create(:estimation) }
  
  describe "estimation_items" do
    it "should be an array" do
      expect(subject.estimation_items).to match_array([])
    end
  end

  describe 'mathematics' do
    it "should calculate sum of all items" do
      2.times do
        subject.estimation_items << FactoryGirl.create(:estimation_item, value: 3)
      end

      expect(subject.sum).to be(6)
    end

    it "should calculate buffer" do
      4.times do
        subject.estimation_items << FactoryGirl.create(:estimation_item, value: 1)
      end
      
      expect(subject.buffer).to be(2.0)
    end

    it 'should calculate total' do
      subject.estimation_items << FactoryGirl.create(:estimation_item, value: 1)

      expect(subject.total).to be(2.0)
    end
  end
end
