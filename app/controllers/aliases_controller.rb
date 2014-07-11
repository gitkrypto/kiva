class AliasesController < ApplicationController
  helper_method :sort_column, :sort_direction
  
  def index
    @aliases = Alias.order(sort_column + " " + sort_direction).paginate(page: params[:page], :per_page => 20)
  end

  def search
    @aliases = Alias.where("alias LIKE ?", "%#{params[:search]}%").order(sort_column + " " + sort_direction).paginate(page: params[:page], :per_page => 20)
  end   
  
  def show
    @alias = Alias.where("lower(alias) = ?", (params[:id]||'').downcase).first
    @aliases = Alias.where("owner = #{@alias.owner.id}").order(sort_column + " " + sort_direction).paginate(page: params[:a_page], :per_page => 20) if @alias
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params.require(:alias).permit(:alias, :txn, :uri, :owner, :search)
    end

    def sort_column
      Alias.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end
    
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end        
end