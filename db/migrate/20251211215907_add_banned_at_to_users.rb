class AddBannedAtToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :banned_at, :datetime
    add_column :users, :banned_by_email, :string
    add_index :users, :banned_at
  end
end
