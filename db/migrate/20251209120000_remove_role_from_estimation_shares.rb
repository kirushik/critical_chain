class RemoveRoleFromEstimationShares < ActiveRecord::Migration[7.2]
  def change
    remove_column :estimation_shares, :role, :string, null: false, default: 'viewer'
  end
end
