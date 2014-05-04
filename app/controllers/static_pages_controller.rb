class StaticPagesController < ApplicationController
  
  def home
    @blocks = Block.limit(6).order("height desc")
    @transactions = Transaction.limit(6).order("timestamp desc")
  end
    
end
