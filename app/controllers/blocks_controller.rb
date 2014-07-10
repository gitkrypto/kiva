class BlocksController < ApplicationController
  helper_method :sort_column, :sort_direction
    
  def index
    @blocks = Block.order(sort_column + " " + sort_direction).paginate(page: params[:page], :per_page => 20)
  end

  def show
    @block = Block.find(params[:id]) rescue nil   
    @block = Block.where(:height => params[:id]).first unless @block
    @block = Block.where(:native_id => params[:id]).first unless @block      
  end

  def total_coins
    current_height = Block.order('height DESC').first.height rescue 0    
    total_coins = 666280000 + (current_height * 200)
    render :json => {
      total_coins: total_coins,
      total_coins_in_circualtion: total_coins - 313000002,
      height: current_height,
      timestamp: Time.now.to_i
    }
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def block_params
      params.require(:block).permit(:height, :native_id, :account, :payload_size_bytes, :total_amount_nqt, :total_fee_nqt, :total_pos_nqt)
    end

    def sort_column
      Block.column_names.include?(params[:sort]) ? params[:sort] : "height"
    end
    
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end      
end