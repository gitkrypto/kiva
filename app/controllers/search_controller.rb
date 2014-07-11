class SearchController < ApplicationController
  
  def search
    text = params[:search]
    type = params[:type]

    if type == 'account'

      # Is it a Account id
      thing = Account.where(:native_id => text).first
      redirect_to account_url(thing) and return if thing
    
      # Is it a Account id
      thing = Account.where(:native_id_rs => text).first
      redirect_to account_url(thing) and return if thing   

      redirect_to "/notfound" and return

    elsif type == 'transaction'

      # Is it a Transaction id
      thing = Transaction.where(:native_id => text).first
      redirect_to transaction_url(thing) and return if thing

      # Is it a Transaction hash
      thing = nil #Transaction.where(:native_id => text).first
      redirect_to transaction_url(thing) and return if thing

      redirect_to "/notfound" and return

    elsif type == 'block'

      # Is it a Block height
      is_number = true if Float(text) rescue false
      if is_number
        thing = Block.where(:height => text.to_i).first
        redirect_to block_url(thing) and return if thing
      end
      
      # Is it a Block id  
      thing = Block.where(:native_id => text).first
      redirect_to block_url(thing) and return if thing
        
      # Is it a Block hash  
      thing = Block.where(:block_signature => text).first
      redirect_to block_url(thing) and return if thing

      redirect_to "/notfound" and return

    elsif type == 'alias'

      # Is it an Alias
      thing = Alias.where("lower(alias) = ?", text.downcase).first
      redirect_to "/aliases/#{thing.alias}" and return if thing

      redirect_to "/notfound" and return   

    end
      
    redirect_to "/notfound"      
  end
  
end
