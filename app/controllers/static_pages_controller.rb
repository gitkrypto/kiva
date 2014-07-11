class StaticPagesController < ApplicationController
  helper_method :sort_column, :sort_direction    
  
  def home
    @blocks = Block.limit(6).order(sort_column + " " + sort_direction)
    @transactions = Transaction.limit(6).order("timestamp desc")
  end

  def notfound
  end
    
  private

    def sort_column
      Block.column_names.include?(params[:sort]) ? params[:sort] : "height"
    end
    
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end     
end
