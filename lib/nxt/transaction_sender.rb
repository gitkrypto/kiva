module NXT  
  class TransactionSender        
    def perform(interval)
      loop do
        ActiveRecord::Base.transaction do
          send_next_transaction
        end
        puts "Going to sleep ... #{interval} seconds"
        sleep interval.to_i
      end
    end
    
    def send_next_transaction
      sender    = random_account(true)
      recipient = random_account
      amountNQT = sender.balance_nqt / rand(10)
      sendmoney(sender, recipient, amountNQT) 
    end
    
    def random_account(positive=false)
      if positive
        Account.where('balance_nqt > 0').order("RANDOM()").first
      else
        Account.order("RANDOM()").first
      end
    end
    
    def sendmoney(sender, recipient, amountNQT, feeNQT=1*NXT::ONE_NXT) 
      t = PendingTransaction.create({
        :sender => sender, :recipient  => recipient, :amount_nqt => amountNQT, :fee_nqt => feeNQT 
      })
      obj = NXT::api.sendMoney(sender.passphrase, recipient.native_id, amountNQT, feeNQT, 1440, "")
      if obj.has_key? 'transaction'
        puts "Transaction Send #{t.amount_nqt} From #{t.sender.native_id} To #{t.recipient.native_id}"
        t.native_id  = obj['transaction']          
      else
        t.error_code = obj['errorCode'] if obj.has_key? 'errorCode'
        t.error_msg  = obj['errorDescription'] if obj.has_key? 'errorDescription'
        t.error_msg  = obj['errorMessage'] if obj.has_key? 'errorMessage'
      end   
      t.save
    end  
  end
end