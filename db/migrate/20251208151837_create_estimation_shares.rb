class CreateEstimationShares < ActiveRecord::Migration[7.2]
  def change
    create_table :estimation_shares do |t|
      t.references :estimation, null: false, foreign_key: true
      t.references :shared_with_user, foreign_key: { to_table: :users }
      t.string :shared_with_email
      t.string :role, null: false, default: 'viewer'
      t.datetime :last_accessed_at

      t.timestamps
    end

    add_index :estimation_shares, [:estimation_id, :shared_with_user_id], unique: true, name: 'index_estimation_shares_on_estimation_and_user'
    add_index :estimation_shares, [:estimation_id, :shared_with_email], unique: true, name: 'index_estimation_shares_on_estimation_and_email'
    add_index :estimation_shares, :shared_with_email
  end
end
