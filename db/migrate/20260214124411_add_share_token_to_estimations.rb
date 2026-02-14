class AddShareTokenToEstimations < ActiveRecord::Migration[7.2]
  def change
    add_column :estimations, :share_token, :string
    add_index :estimations, :share_token, unique: true
  end
end
