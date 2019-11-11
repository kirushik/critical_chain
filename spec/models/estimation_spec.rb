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
  subject { FactoryBot.create(:estimation) }

  describe '#estimation_items' do
    it "should be an array" do
      expect(subject.estimation_items).to match_array([])
    end
  end

  describe 'mathematics' do
    it "should calculate sum of all items" do
      2.times do
        subject.estimation_items << FactoryBot.create(:estimation_item, value: 3)
      end

      expect(subject.sum).to eq 6
    end

    it 'should calculate buffer' do
      4.times do
        subject.estimation_items << FactoryBot.create(:estimation_item, value: 1)
      end

      expect(subject.buffer).to eq 2
    end

    it 'should calculate total' do
      subject.estimation_items << FactoryBot.create(:estimation_item, value: 1)

      expect(subject.total).to eq 2
    end

    context 'with fixed items' do
      it 'should yield zero buffer if only fixed items present' do
        subject.estimation_items << FactoryBot.create(:estimation_item, value: 1, fixed: true)
        subject.estimation_items << FactoryBot.create(:estimation_item, value: 1, fixed: true)

        expect(subject.buffer).to eq 0
      end

      it 'should count buffers ignoring fixed items' do
        4.times do
          subject.estimation_items << FactoryBot.create(:estimation_item, value: 1)
          subject.estimation_items << FactoryBot.create(:estimation_item, value: 1, fixed: true)
        end

        expect(subject.sum).to eq 8
        expect(subject.buffer).to eq 2
        expect(subject.total).to eq 10
      end
    end

    context 'with batch items' do
      it 'takes quantity in account' do
        subject.estimation_items << FactoryBot.create(:estimation_item, value: 1, quantity: 4)

        expect(subject.sum).to eq 4
        expect(subject.buffer).to eq 2
        expect(subject.total).to eq 6
      end

      it 'can mix batches and ordinary items' do
        subject.estimation_items << FactoryBot.create(:estimation_item, value: 1, quantity: 3)
        subject.estimation_items << FactoryBot.create(:estimation_item, value: 1)

        expect(subject.sum).to eq 4
        expect(subject.buffer).to eq 2
        expect(subject.total).to eq 6
      end

      it 'avoids fixed items in calculations' do
        subject.estimation_items << FactoryBot.create(:estimation_item, value: 1, quantity: 4)
        subject.estimation_items << FactoryBot.create(:estimation_item, value: 10, fixed: true)

        expect(subject.sum).to eq 14
        expect(subject.buffer).to eq 2
        expect(subject.total).to eq 16
      end
    end
  end

  describe 'deletions' do
    it 'should happen with dependent items' do
      2.times do
        subject.estimation_items << FactoryBot.create(:estimation_item, value: 3)
      end

      expect(EstimationItem.count).to eq(2)

      subject.destroy!

      expect(EstimationItem.count).to eq(0)
    end
  end

  describe '#completed_items' do
    it 'should list only items with actual_value set' do
      FactoryBot.create(:estimation_item, estimation: subject)
      completed_item = FactoryBot.create(:estimation_item, estimation: subject, actual_value: 1)

      expect(subject.completed_items).to contain_exactly completed_item
    end
  end

  describe '#project_progress' do
    subject { FactoryBot.create :estimation_with_items, items: {count: 9, size: 1} }

    it 'should be zero when no items are finished' do
      expect(subject.project_progress).to eq 0
    end

    it 'should be zero for empty project' do
      estimation = FactoryBot.create :estimation
      expect(estimation.project_progress).to eq 0
    end

    it 'should be a fraction of estimations' do
      FactoryBot.create :estimation_item, value: 1, actual_value: 1, estimation: subject
      expect(subject.project_progress).to eq 0.1
    end

    it 'should be 1 when all items are finished' do
      subject.estimation_items.update_all(actual_value: 1)
      expect(subject.project_progress).to eq 1
    end
  end

  describe '#buffer_consumption' do
    subject { FactoryBot.create :estimation_with_items, items: {count: 9, size: 10} }

    it 'is zero when no items completed' do
      expect(subject.buffer_consumption).to eq 0
    end

    it 'is zero for empty project' do
      estimation = FactoryBot.create :estimation
      expect(estimation.buffer_consumption).to eq 0
    end

    it 'is zero when all completed items took exactly their estimated values' do
      subject.estimation_items.update_all(actual_value: 10)
      expect(subject.buffer_consumption).to eq 0
    end

    it 'is zero when all items have been overestimated' do
      subject.estimation_items.update_all(actual_value: 1)
      expect(subject.buffer_consumption).to eq 0
    end

    it 'is 0.1 when 10% of the total buffer spent' do
      subject.estimation_items.first.update_attribute(:actual_value, 12)
      subject.estimation_items.second.update_attribute(:actual_value, 11)
      expect(subject.buffer_consumption).to eq 0.1
    end

    it 'is 1.0 when all the buffer is spent' do
      subject.estimation_items.first.update_attribute(:actual_value, 40)
      expect(subject.buffer_consumption).to eq 1.0
    end

    it 'can be more than 1.0' do
      subject.estimation_items.first.update_attribute(:actual_value, 399)
      expect(subject.buffer_consumption).to be > 1.0
    end
  end

  describe '#buffer_health' do
    subject { FactoryBot.create :estimation_with_items, items: {count: 4, size: 10} }

    it 'is 0.0 when no actual progress happened' do
      expect(subject.buffer_health).to eq 0
    end

    it 'is 0.0 when no bufer consumed' do
      subject.estimation_items.first.update_attribute(:actual_value, 8)
      subject.estimation_items.second.update_attribute(:actual_value, 6)
      expect(subject.buffer_health).to eq 0
    end

    it 'is 1.0 when buffer consumption happens at par with project progress' do
      subject.estimation_items.first.update_attribute(:actual_value, 13)
      subject.estimation_items.second.update_attribute(:actual_value, 17)
      expect(subject.buffer_health).to eq 1
    end

    it 'is 0.1 when buffer is spent slower' do
      subject.estimation_items.first.update_attribute(:actual_value, 10.5)
      expect(subject.buffer_health).to eq 0.1
    end

    it 'is working when some items underuse buffer, and some - overuse it' do
      subject.estimation_items.first.update_attribute(:actual_value, 9)
      subject.estimation_items.second.update_attribute(:actual_value, 12)
      expect(subject.buffer_health).to eq 0.1
    end

    it 'can be more that 1.0' do
      subject.estimation_items.first.update_attribute(:actual_value, 20)
      expect(subject.buffer_health).to eq 2
    end
  end
end
