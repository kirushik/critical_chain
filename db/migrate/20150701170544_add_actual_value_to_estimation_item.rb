class AddActualValueToEstimationItem < ActiveRecord::Migration
  def change
    add_column :estimation_items, :actual_value, :float
  end
end
