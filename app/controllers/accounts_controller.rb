class AccountsController < ApplicationController
  
  def index
    @accounts = Account.paginate(page: params[:page], :per_page => 20)
  end

  def show
    @account = Account.find(params[:id])
    @transactions = Transaction.where("sender = #{@account.id} OR recipient = #{@account.id}")
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params.require(:account).permit(:native_id, :balance_nqt, :total_pos_rewards_nqt)
    end
end
