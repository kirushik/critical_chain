class AddActualValueToEstimationItem < ActiveRecord::Migration[4.2]
  def change
    add_column :estimation_items, :actual_value, :float
  end
end
