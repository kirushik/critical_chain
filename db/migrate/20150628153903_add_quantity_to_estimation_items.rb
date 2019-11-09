class AddQuantityToEstimationItems < ActiveRecord::Migration[4.2]
  def change
    add_column :estimation_items, :quantity, :integer, null: false, default: 1
  end
end
