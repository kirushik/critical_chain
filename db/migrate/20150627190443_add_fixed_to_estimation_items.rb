class AddFixedToEstimationItems < ActiveRecord::Migration[4.2]
  def change
    add_column :estimation_items, :fixed, :boolean, null: false, default: false
  end
end
