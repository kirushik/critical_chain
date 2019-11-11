class AddTrackingModeToEstimations < ActiveRecord::Migration[4.2]
  def change
    add_column :estimations, :tracking_mode, :boolean, null: false, default: false
  end
end
