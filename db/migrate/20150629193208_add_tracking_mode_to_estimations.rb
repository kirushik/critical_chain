class AddTrackingModeToEstimations < ActiveRecord::Migration
  def change
    add_column :estimations, :tracking_mode, :boolean, null: false, default: false
  end
end
