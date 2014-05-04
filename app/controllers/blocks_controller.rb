class BlocksController < ApplicationController
  before_action :set_block, only: [:show]
    
  def index
    @blocks = Block.order('height DESC').paginate(page: params[:page], :per_page => 20)
  end

  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_block
      @block = Block.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def block_params
      params.require(:block).permit(:height, :native_id, :account, :payload_size_bytes, :total_amount_nqt, :total_fee_nqt, :total_pos_nqt)
    end
end