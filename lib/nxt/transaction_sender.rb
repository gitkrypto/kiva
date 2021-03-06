module NXT  
  class TransactionSender        
    def perform(interval)
      begin
        loop do
          send_next_transaction
          puts "Going to sleep ... #{interval} seconds" if NXT.verbose
          sleep interval.to_i
        end
      rescue => e
        log("Error: #{$!}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
        throw e
      end
    end
    
    def log(msg)
      NXT.log('txn sender', msg)
    end
    
    def send_next_transaction
      sender    = random_account(true)
      unless sender
        log "Could not obtain a random account for Transaction Sender"
        return
      end      
      recipient = random_account
      amountNQT = sender.balance_nqt / (rand(10)+1)
      sendmoney(sender, recipient, amountNQT) 
    end
    
    def random_account(positive=false)
      if positive
        Account.where('balance_nqt > 0').order("RAND()").first
      else
        Account.order("RAND()").first
      end
    end
    
    def sendmoney(sender, recipient, amountNQT, feeNQT=MIN_FEE_NQT)      
      #puts "Sendmoney sender=#{sender} #{sender.passphrase}"
      ActiveRecord::Base.transaction do
        t = PendingTransaction.create({
          :sender => sender, :recipient  => recipient, :amount_nqt => amountNQT, :fee_nqt => feeNQT 
        })
        obj = NXT::api.sendMoney(sender.passphrase, recipient.native_id, amountNQT, feeNQT, 1440, "")
        if obj.has_key? 'transaction' and not obj.has_key? 'error'
          log "Send #{t.amount_nqt} from:#{t.sender.native_id} to:#{t.recipient.native_id}" if NXT.verbose
          t.native_id  = obj['transaction']          
        else
          t.error_code = obj['errorCode'] if obj.has_key? 'errorCode'
          t.error_msg  = obj['errorDescription'] if obj.has_key? 'errorDescription'
          t.error_msg  = obj['errorMessage'] if obj.has_key? 'errorMessage'
          t.error_msg  = obj['error'] if obj.has_key? 'error'
          log "Failed to Send #{t.amount_nqt} from:#{t.sender.native_id_rs} to:#{t.recipient.native_id_rs} | #{t.error_msg}" if NXT.verbose
        end   
        t.save
      end
    end  
  end
end