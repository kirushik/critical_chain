class AddQuantityToEstimationItems < ActiveRecord::Migration
  def change
    add_column :estimation_items, :quantity, :integer, null: false, default: 1
  end
end
