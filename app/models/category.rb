class Category < ApplicationRecord
  has_many :transactions, dependent: :restrict_with_error
  has_many :children, class_name: "Category", foreign_key: :parent_id, dependent: :destroy
  belongs_to :parent, class_name: "Category", optional: true

  enum :category_type, {
    expense: 0,
    income: 1
  }, prefix: true

  validates :name, presence: true
  validates :category_type, presence: true

  scope :expenses, -> { where(category_type: :expense) }
  scope :incomes, -> { where(category_type: :income) }
  scope :roots, -> { where(parent_id: nil) }

  def display_type
    category_type_expense? ? "Despesa" : "Receita"
  end

  def full_name
    parent ? "#{parent.name} > #{name}" : name
  end

  def self.collection_for_select
    roots.order(:name).map do |category|
      [ category.name, category.id, { children: category.children.order(:name).map { |c| [ c.name, c.id ] } } ]
    end
  end
end
