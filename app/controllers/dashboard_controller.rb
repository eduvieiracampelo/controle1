class DashboardController < ApplicationController
  def index
    @accounts = Account.order(:name)
    @total_balance = @accounts.sum(&:balance)

    @current_month = Date.current.beginning_of_month
    @current_month_end = Date.current.end_of_month

    @monthly_transactions = Transaction.by_period(@current_month, @current_month_end)
    @monthly_income = @monthly_transactions.incomes.sum(:amount)
    @monthly_expense = @monthly_transactions.expenses.sum(:amount).abs
    @monthly_balance = @monthly_income - @monthly_expense

    @recent_transactions = Transaction.by_date.includes(:category).limit(5)
    @top_expenses = Transaction.by_period(@current_month, @current_month_end)
      .expenses
      .joins(:category)
      .group("categories.name")
      .order("SUM(transactions.amount) DESC")
      .limit(5)
      .sum("transactions.amount")
      .map { |name, amount| [ name, amount.abs ] }
  end
end
