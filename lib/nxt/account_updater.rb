module NXT

  class AccountUpdater

    def perform(interval)
      begin
        loop do
          StaleAccount.all.order("id asc").limit(20).each do |stale_account|
            if update_account(stale_account.native_id)
              stale_account.delete
            end
          end
          puts "Going to sleep ... #{interval} seconds" if NXT.verbose
          sleep interval.to_i
        end
      rescue => e
        log("Error: #{$!}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
        throw e
      end
    end

    def log(msg)
      NXT.log('account updater', msg)
    end    

    def update_account(native_id)
      json = NXT::api.getAccount(native_id)
      return false if NXT.is_error(json) || !json['balanceNQT']

      account = Account.where(:native_id => native_id).first

      account.balance_nqt = json['balanceNQT']
      account.pos_balance_nqt = json['forgedBalanceNQT']
      account.public_key = json['publicKey']
      account.save
      return true
    end
  end

end