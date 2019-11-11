class CreateEstimations < ActiveRecord::Migration[4.2]
  def change
    create_table :estimations do |t|
      t.string :title
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :estimations, :users
  end
end
