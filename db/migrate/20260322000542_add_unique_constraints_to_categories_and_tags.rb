class AddUniqueConstraintsToCategoriesAndTags < ActiveRecord::Migration[8.1]
  def change
    add_index :categories, :name, unique: true
    add_index :tags, :name, unique: true
  end
end
