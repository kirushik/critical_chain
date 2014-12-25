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

class Estimation < ActiveRecord::Base
  belongs_to :user
end
