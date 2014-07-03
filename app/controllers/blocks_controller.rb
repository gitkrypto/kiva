class BlocksController < ApplicationController
    
  def index
    @blocks = Block.order('height DESC').paginate(page: params[:page], :per_page => 20)
  end

  def show
    @block = Block.find(params[:id]) rescue nil   
    @block = Block.where(:native_id => params[:id]).first unless @block      
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def block_params
      params.require(:block).permit(:height, :native_id, :account, :payload_size_bytes, :total_amount_nqt, :total_fee_nqt, :total_pos_nqt)
    end
end