module NXT
  class AccountGenerator
    def perform
      add_stakeholder_accounts
      add_csv_accounts
    end
    
    # Generate all Stakeholder accounts
    def add_stakeholder_accounts
      puts "Generating Stakeholder Accounts"
      ActiveRecord::Base.transaction do
        accounts  = Fuzzer::Genesis.accounts
        accounts  = accounts.slice(0..20) if NXT::DEBUG        
        
        accounts.each_with_index do |native_id, index| 
          puts "Adding Stakeholder Account #{index} ..." if index % 100 == 0
          passphrase  = Fuzzer::Genesis.keys[index] 
          Account.create({:native_id => native_id, :passphrase => passphrase})
        end
      end
    end
    
    # Generate all accounts in the accounts.csv monster list
    def add_csv_accounts
      puts "Generating Accounts From accounts.csv"
      count    = 0
      accounts = CSV.read("#{Rails.root}/lib/nxt/accounts.csv")
      accounts = accounts.slice(0..600) if NXT::DEBUG      
      accounts.each_slice(100) do |arr|
        puts "Adding Account #{count} ..."
        ActiveRecord::Base.transaction do
          arr.each do |row|
            count += 1
            Account.create({:native_id => row[0], :passphrase => row[1]})
          end
        end
      end
    end
  end
end