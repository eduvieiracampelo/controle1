class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.text :description
      t.integer :transaction_type, null: false, default: 0
      t.date :date, null: false
      t.boolean :paid, default: false
      t.references :account, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.integer :source_account_id
      t.integer :installment_number
      t.integer :total_installments

      t.timestamps
    end

    add_index :transactions, :date
    add_index :transactions, :transaction_type
    add_index :transactions, :paid
  end
end
