class UnconfirmedTransactionsController < ApplicationController
  include ApplicationHelper
  before_action :set_transaction, only: [:show]

  def index
    @unconfirmed_transactions = UnconfirmedTransaction.order('id DESC').paginate(page: params[:page], :per_page => 20)
  end

  def show
  end
  
  def latest
    transactions = UnconfirmedTransaction.order('id DESC').limit(10)
    result       = []
    transactions.each do |transaction|
      result << {
        :sender     => transaction.sender.native_id,
        :recipient  => transaction.recipient.native_id,
        :amount     => convert_to_nxt(transaction.amount_nqt),
        :fee        => convert_to_nxt(transaction.fee_nqt),
        :id         => transaction.native_id,
        :time       => convert_timestamp(transaction.timestamp)
      }
    end
    render json: result
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @unconfirmed_transaction = UnconfirmedTransaction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_params
      params.require(:transaction).permit(:native_id, :block, :sender, :recipient, :amount_nqt, :fee_nqt)
    end
end