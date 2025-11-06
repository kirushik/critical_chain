class AddOrderToEstimationItems < ActiveRecord::Migration[7.2]
  def change
    add_column :estimation_items, :order, :float, default: 0.0, null: false
    
    # Set initial order based on id for existing items
    reversible do |dir|
      dir.up do
        EstimationItem.reset_column_information
        EstimationItem.find_each do |item|
          item.update_column(:order, item.id.to_f)
        end
      end
    end
    
    add_index :estimation_items, [:estimation_id, :order]
  end
end
