# == Schema Information
#
# Table name: estimations
#
#  id            :integer          not null, primary key
#  title         :string
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tracking_mode :boolean          default(FALSE), not null
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

      expect(subject.sum).to eq 6
    end

    it "should calculate buffer" do
      4.times do
        subject.estimation_items << FactoryGirl.create(:estimation_item, value: 1)
      end
      
      expect(subject.buffer).to eq 2
    end

    it 'should calculate total' do
      subject.estimation_items << FactoryGirl.create(:estimation_item, value: 1)

      expect(subject.total).to eq 2
    end

    context 'with fixed items' do
      it 'should yield zero buffer if only fixed items present' do
        subject.estimation_items << FactoryGirl.create(:estimation_item, value: 1, fixed: true)
        subject.estimation_items << FactoryGirl.create(:estimation_item, value: 1, fixed: true)

        expect(subject.buffer).to eq 0
      end

      it 'should count buffers ignoring fixed items' do
        4.times do
          subject.estimation_items << FactoryGirl.create(:estimation_item, value: 1)
          subject.estimation_items << FactoryGirl.create(:estimation_item, value: 1, fixed: true)
        end

        expect(subject.sum).to eq 8
        expect(subject.buffer).to eq 2
        expect(subject.total).to eq 10
      end
    end

    context 'with batch items' do
      it 'takes quantity in account' do
        subject.estimation_items << FactoryGirl.create(:estimation_item, value: 1, quantity: 4)

        expect(subject.sum).to eq 4
        expect(subject.buffer).to eq 2
        expect(subject.total).to eq 6
      end

      it 'can mix batches and ordinary items' do
        subject.estimation_items << FactoryGirl.create(:estimation_item, value: 1, quantity: 3)
        subject.estimation_items << FactoryGirl.create(:estimation_item, value: 1)

        expect(subject.sum).to eq 4
        expect(subject.buffer).to eq 2
        expect(subject.total).to eq 6
      end

      it 'avoids fixed items in calculations' do
        subject.estimation_items << FactoryGirl.create(:estimation_item, value: 1, quantity: 4)
        subject.estimation_items << FactoryGirl.create(:estimation_item, value: 10, fixed: true)

        expect(subject.sum).to eq 14
        expect(subject.buffer).to eq 2
        expect(subject.total).to eq 16
      end
    end
  end

  describe 'deletions' do
    it 'should happen with dependent items' do
      2.times do
        subject.estimation_items << FactoryGirl.create(:estimation_item, value: 3)
      end
      
      expect(EstimationItem.count).to eq(2)

      subject.destroy!

      expect(EstimationItem.count).to eq(0)
    end
  end
end
