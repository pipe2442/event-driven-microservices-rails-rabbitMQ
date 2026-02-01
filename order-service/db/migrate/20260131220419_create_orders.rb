class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.uuid :public_id, null: false, default: "gen_random_uuid()"
      t.uuid :customer_public_id, null: false

      t.string :product_name, null: false
      t.integer :quantity, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.text :delivery_address, null: false

      t.string :status, null: false, default: "created"

      t.timestamps
    end

    add_index :orders, :public_id, unique: true
    add_index :orders, :customer_public_id
  end
end
