class AccountsController < ApplicationController
  before_action :set_account, only: [ :show, :edit, :update, :destroy ]

  def index
    @accounts = Account.order(:name)
    @total_balance = @accounts.sum(&:balance)
  end

  def show; end

  def new
    @account = Account.new
  end

  def edit; end

  def create
    @account = Account.new(account_params)
    if @account.save
      redirect_to @account, notice: "Conta criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @account.update(account_params)
      redirect_to @account, notice: "Conta atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @account.destroy
    redirect_to accounts_path, notice: "Conta excluída com sucesso."
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:name, :account_type, :balance, :credit_limit, :color, :icon)
  end
end
