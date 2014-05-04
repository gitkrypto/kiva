class AccountsController < ApplicationController
  before_action :set_account, only: [:show]
  
  def index
    @accounts = Account.paginate(page: params[:page], :per_page => 20)
  end

  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params.require(:account).permit(:native_id, :balance_nqt, :total_pos_rewards_nqt)
    end
end
