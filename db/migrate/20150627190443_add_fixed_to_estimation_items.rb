class AddFixedToEstimationItems < ActiveRecord::Migration
  def change
    add_column :estimation_items, :fixed, :boolean, null: false, default: false
  end
end
