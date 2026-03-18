class TransactionsController < ApplicationController
  before_action :set_transaction, only: [ :show, :edit, :update, :destroy ]
  before_action :load_collections, only: [ :index, :new, :edit, :create, :update ]

  def index
    @transactions = Transaction.by_date
    @transactions = @transactions.by_period(params[:start_date], params[:end_date]) if params[:start_date].present?
    @transactions = @transactions.by_account(params[:account_id]) if params[:account_id].present?
    @transactions = @transactions.by_category(params[:category_id]) if params[:category_id].present?
    @transactions = @transactions.by_type(params[:transaction_type]) if params[:transaction_type].present?

    @total_expenses = @transactions.expenses.sum(:amount).abs
    @total_incomes = @transactions.incomes.sum(:amount)
    @total_balance = @total_incomes - @total_expenses
  end

  def show; end

  def new
    @transaction = Transaction.new
    @transaction.date = Date.current if params[:date].blank?
  end

  def edit; end

  def create
    @transaction = Transaction.new(transaction_params)
    if @transaction.save
      update_account_balance(@transaction)
      redirect_to @transaction, notice: "Transação criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    old_amount = @transaction.amount
    if @transaction.update(transaction_params)
      update_account_balance(@transaction, old_amount)
      redirect_to @transaction, notice: "Transação atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    update_account_balance(@transaction, reverse: true)
    @transaction.destroy!
    redirect_to transactions_path, notice: "Transação excluída com sucesso."
  end

  private

  def set_transaction
    @transaction = Transaction.find(params[:id])
  end

  def load_collections
    @accounts = Account.order(:name)
    @categories = Category.order(:name)
    @tags = Tag.order(:name)
  end

  def transaction_params
    params.require(:transaction).permit(:amount, :description, :transaction_type, :date, :paid, :account_id, :category_id, :installment_number, :total_installments, tag_ids: [])
  end

  def update_account_balance(transaction, old_amount = nil, reverse: false)
    account = transaction.account
    amount = transaction.amount.to_f

    multiplier = reverse ? -1 : 1
    if old_amount
      adjustment = (amount - old_amount.to_f) * multiplier
    else
      adjustment = amount * multiplier
    end

    case transaction.transaction_type.to_sym
    when :expense
      account.balance -= adjustment.abs
    when :income
      account.balance += adjustment.abs
    end
    account.save!
  end
end
