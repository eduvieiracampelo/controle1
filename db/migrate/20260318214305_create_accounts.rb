class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.integer :account_type, null: false, default: 0
      t.decimal :balance, precision: 12, scale: 2, default: 0
      t.decimal :credit_limit, precision: 12, scale: 2, default: 0
      t.string :color, default: "#3B82F6"
      t.string :icon, default: "wallet"

      t.timestamps
    end

    add_index :accounts, :account_type
  end
end
