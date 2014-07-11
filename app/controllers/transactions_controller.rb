class TransactionsController < ApplicationController
  include ApplicationHelper
  helper_method :sort_column, :sort_direction    

  def index
    @transactions = Transaction.order(sort_column + " " + sort_direction).paginate(page: params[:page], :per_page => 20)
  end

  def show
    @transaction = Transaction.find(params[:id]) rescue nil   
    @transaction = Transaction.where(:native_id => params[:id]).first unless @transaction
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_params
      params.require(:transaction).permit(:native_id, :block, :sender, :recipient, :amount_nqt, :fee_nqt)
    end

    def sort_column
      Transaction.column_names.include?(params[:sort]) ? params[:sort] : "timestamp"
    end
    
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end          
end