class BlocksController < ApplicationController
  helper_method :sort_column, :sort_direction
    
  def index
    @blocks = Block.order(sort_column + " " + sort_direction).paginate(page: params[:page], :per_page => 20)
  end

  def search
    @blocks = Block.where("native_id LIKE ?", "%#{params[:search]}%").order(sort_column + " " + sort_direction).paginate(page: params[:page], :per_page => 20)
  end  

  def show
    @block = Block.find(params[:id]) rescue nil   
    @block = Block.where(:height => params[:id]).first unless @block
    @block = Block.where(:native_id => params[:id]).first unless @block      
  end

  def stats
    @from_height = params[:from_height].to_i || 0
    @to_height = params[:to_height].to_i || 2880
    current_height = Block.order('height DESC').first.height rescue 0

    if @from_height == 0 && @to_height == 0
      @to_height = current_height
      @from_height = [@to_height - 2880, 0].max
      redirect_to "/blocks/stats/#{@from_height}/#{@to_height}" and return
    end

    @to_height = [@from_height + @to_height, @from_height + 2880].min

    @blocks = Block.where("height >= ? AND height <= ?", @from_height, @to_height)

    @from_timestamp = @blocks.first.timestamp rescue 0
    @to_timestamp = @blocks.last.timestamp rescue 0

    @stats = {}
    @blocks.find_each do |b| 
      stat = @stats[b.generator_id] = @stats[b.generator_id] || 
                                      @stats[b.generator_id] = { :blocks => [], :account => b.generator, :total_pos_rewards_nqt => 0 }
      stat[:blocks] << b
      stat[:total_pos_rewards_nqt] += b.total_pos_nqt + b.total_fee_nqt
    end
    @stats = @stats.values.sort_by { |s| s[:blocks].count }
    @stats.reverse!   

    @periods = []
    30.times do |i|
      from = current_height - (i*2880)
      to   = [from + 2880, current_height].min
      next if from == to
      from = [0,from].max
      @periods << [from, to]
      break if from == 0
    end
  end

  def total_coins
    current_height = Block.order('height DESC').first.height rescue 0    
    total_coins = 666280000 + (current_height * 200)
    render :json => {
      total_coins: total_coins,
      coins_in_circulation: total_coins - 313000002,
      height: current_height,
      timestamp: Time.now.to_i
    }
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def block_params
      params.require(:block).permit(:height, :native_id, :account, :payload_size_bytes, :total_amount_nqt, :total_fee_nqt, :total_pos_nqt, :search, :from_height, :to_height)
    end

    def sort_column
      Block.column_names.include?(params[:sort]) ? params[:sort] : "height"
    end
    
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end      
end