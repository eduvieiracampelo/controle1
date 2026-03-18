class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.integer :category_type, null: false, default: 0
      t.string :icon, default: "tag"
      t.string :color, default: "#10B981"
      t.references :parent, foreign_key: { to_table: :categories }

      t.timestamps
    end

    add_index :categories, :category_type
  end
end
