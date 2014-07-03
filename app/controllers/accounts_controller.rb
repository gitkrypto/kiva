class AccountsController < ApplicationController
  
  def index
    @accounts = Account.paginate(page: params[:page], :per_page => 20)
  end

  def show
    @account = Account.find(params[:id]) rescue nil
    @account = (Account.where(:native_id => params[:id]).first rescue nil) unless @account
    @account = Account.where(:native_id_rs => params[:id]).first unless @account
      
    
      
    @transactions = Transaction.where("sender = #{@account.id} OR recipient = #{@account.id}").paginate(page: params[:page], :per_page => 10)
  end
  
  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params.require(:account).permit(:native_id, :balance_nqt, :total_pos_rewards_nqt)
    end
end
