class Account < ApplicationRecord
  has_many :transactions, dependent: :destroy

  enum :account_type, {
    checking: 0,
    savings: 1,
    wallet: 2,
    credit_card: 3
  }, prefix: true

  validates :name, presence: true
  validates :account_type, presence: true
  validates :balance, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :credit_limit, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true, allow_nil: true

  scope :active, -> { where("balance != 0 OR credit_limit > 0") }

  def total_limit
    credit_limit.to_f
  end

  def available_credit
    return 0 unless account_type_credit_card?

    credit_limit.to_f - transactions.where("date <= ?", Date.current.end_of_month).sum(:amount).abs
  end

  def display_type
    case account_type.to_sym
    when :checking then "Conta Corrente"
    when :savings then "Poupança"
    when :wallet then "Carteira"
    when :credit_card then "Cartão de Crédito"
    end
  end
end
