class CreateEstimationItems < ActiveRecord::Migration
  def change
    create_table :estimation_items do |t|
      t.integer :value
      t.string :title
      t.references :estimation, index: true

      t.timestamps null: false
    end
    add_foreign_key :estimation_items, :estimations
  end
end
