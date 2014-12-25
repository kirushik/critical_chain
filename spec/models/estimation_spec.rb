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
end
