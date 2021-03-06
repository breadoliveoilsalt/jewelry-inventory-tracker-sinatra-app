class CreateInventoryItems < ActiveRecord::Migration
  def change
    create_table :inventory_items do |t|
      t.string :seller
      t.boolean :sold, null: false, default: false
      t.integer :user_id
      t.integer :seller_id
      t.integer :product_line_id
      t.timestamps null: true
    end
  end
end
