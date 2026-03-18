class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :category

  has_many :transaction_tags, dependent: :destroy
  has_many :tags, through: :transaction_tags, source: :tag

  enum :transaction_type, {
    expense: 0,
    income: 1,
    transfer: 2
  }, prefix: true

  validates :amount, presence: true, numericality: { not_equal_to: 0 }
  validates :date, presence: true
  validates :transaction_type, presence: true
  validates :category, presence: true
  validates :account, presence: true

  scope :by_date, -> { order(date: :desc, created_at: :desc) }
  scope :by_period, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :by_account, ->(account_id) { where(account_id: account_id) if account_id.present? }
  scope :by_category, ->(category_id) { where(category_id: category_id) if category_id.present? }
  scope :by_type, ->(type) { where(transaction_type: type) if type.present? }
  scope :expenses, -> { where(transaction_type: :expense) }
  scope :incomes, -> { where(transaction_type: :income) }
  scope :paid, -> { where(paid: true) }

  before_validation :set_default_date, on: :create

  def display_type
    case transaction_type.to_sym
    when :expense then "Despesa"
    when :income then "Receita"
    when :transfer then "Transferência"
    end
  end

  def signed_amount
    case transaction_type.to_sym
    when :expense then -amount.to_f
    when :income then amount.to_f
    when :transfer then 0
    end
  end

  private

  def set_default_date
    self.date ||= Date.current
  end
end
