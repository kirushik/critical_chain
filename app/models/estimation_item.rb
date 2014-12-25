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
#
# Indexes
#
#  index_estimation_items_on_estimation_id  (estimation_id)
#

class EstimationItem < ActiveRecord::Base
  belongs_to :estimation
end
