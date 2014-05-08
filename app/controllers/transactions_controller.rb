class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show]

  def index
    @transactions = Transaction.order('block DESC').paginate(page: params[:page], :per_page => 20)
  end

  def show
  end
  
  # json
  def latest
    #list = Transaction.limit(6).order("timestamp desc")
    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_params
      params.require(:transaction).permit(:native_id, :block, :sender, :recipient, :amount_nqt, :fee_nqt)
    end
end