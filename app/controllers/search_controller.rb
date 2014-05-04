class SearchController < ApplicationController
  
  def search
    text = params[:search]
      
    # Is it a Block height
    thing = Block.where(:height => text.to_i).first
    redirect_to block_url(thing) and return if thing
    
    # Is it a Block id  
    thing = Block.where(:native_id => text).first
    redirect_to block_url(thing) and return if thing
      
    # Is it a Block hash  
    thing = Block.where(:block_signature => text).first
    redirect_to block_url(thing) and return if thing
      
    # Is it a Transaction id
    thing = Transaction.where(:native_id => text).first
    redirect_to transaction_url(thing) and return if thing

    # Is it a Transaction hash
    thing = nil #Transaction.where(:native_id => text).first
    redirect_to transaction_url(thing) and return if thing
  
    # Is it a Account id
    thing = Account.where(:native_id => text).first
    redirect_to account_url(thing) and return if thing
    
    # Is it a Account public key
    thing = nil # Account.where(:native_id => text).first
    redirect_to account_url(thing) and return if thing
    
    redirect_to '/'
  end
  
end
