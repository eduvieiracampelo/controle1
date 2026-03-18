class TransactionTag < ApplicationRecord
  belongs_to :tag
  belongs_to :transaction_record, class_name: "Transaction", foreign_key: "transaction_id"

  validates :transaction_id, uniqueness: { scope: :tag_id }
end
