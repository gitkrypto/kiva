module NXT
  class TransactionPoller    
    def perform(interval)
      begin
        loop do
          opts = NXT::api.getUnconfirmedTransactionsIds
          if opts.has_key? 'unconfirmedTransactionIds'
            add_new_transactions opts['unconfirmedTransactionIds']
          end
          #puts "Going to sleep ... #{interval} seconds"
          sleep interval.to_i
        end
      rescue => e
        log("Error: #{$!}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
        throw e
      end
    end

    def log(msg)
      NXT.log('txn poller', msg)
    end

    # Add unconfirmed transactions 
    # @param transactionIds ["id1", "id2"]
    def add_new_transactions(transactionIds)
      transactionIds.each do |native_id|
        download_transaction(native_id) unless get_transaction(native_id)
      end
    end

    # Downloads and stores a Transaction
    def download_transaction(native_id)
      json = NXT::api.getTransaction(native_id)
      # Create a new db transaction
      transaction = UnconfirmedTransaction.create!({
        :native_id        => native_id,
        :sender           => get_account(json['sender']),
        :recipient        => get_account(json['recipient']),  
        :amount_nqt       => json['amountNQT'],
        :fee_nqt          => json['feeNQT'],
        :timestamp        => json['timestamp']  
      })
    end

    def logger
      Rails.logger
    end

    def get_account(native_id)
      Account.where(:native_id => native_id).first_or_create
    end

    def get_transaction(native_id)
      UnconfirmedTransaction.where(:native_id => native_id).first
    end
  end
end