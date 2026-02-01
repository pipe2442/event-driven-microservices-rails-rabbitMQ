class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.uuid :public_id, null: false, default: "gen_random_uuid()"

      t.string :name, null: false
      t.text :address, null: false
      t.integer :orders_count, null: false, default: 0

      t.timestamps
    end

    add_index :customers, :public_id, unique: true
    add_index :customers, :name
  end
end
