module NXT
  class TestGenerator
        
    TOTAL_RANDOM_GIVEAWAY_COUNT = NXT::DEBUG ? 100 : 10000
    MAX_GIVEAWAY_AMOUNT_NQT     = 100 * ONE_NXT
    
    def perform
      add_csv_accounts
      add_stakeholder_accounts  
      stakeholder_giveaway
#      random_give_away
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
            Account.where(:native_id => row[0], :passphrase => row[1]).first_or_create
          end
        end
      end
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
          Account.where(:native_id => native_id, :passphrase => passphrase).first_or_create
        end
      end
    end
    
    # Give away stakeholder amounts
    def stakeholder_giveaway
      puts "Generating Stakeholder Giveaway Transactions"
      per_genesis   = (Account.count / Fuzzer::Genesis.keys.length) + 1;
      count         = 0 
      total_stakes  = Fuzzer::Genesis.keys.count  
      total_stakes  = 100 if NXT::DEBUG
      
      (0..total_stakes).each_slice(10) do |slice|
        ActiveRecord::Base.transaction do
          slice.each do |index|
            native_id     = Fuzzer::Genesis.accounts[index]
            total_amount  = Fuzzer::Genesis.amounts[index]
            sender        = get_account(native_id)
            
            per_genesis.times do
              puts "Adding Stakeholder Giveaway Transaction #{count} ..." if count % 100 == 0
              count      += 1
              amountNQT   = (total_amount / per_genesis) * ONE_NXT
              recipient   = random_account
              sendmoney(sender, recipient, amountNQT)          
            end
          end
        end
      end
    end
    
    # Generate random give-aways
    def random_give_away
      puts "Generating Random Giveaway Transactions"
      count = 0
      
      (0..TOTAL_RANDOM_GIVEAWAY_COUNT).each_slice(100) do |slice|
        ActiveRecord::Base.transaction do
          slice.each do
            puts "Random Giveaway Transaction #{count} ..." if count % 100 == 0
            count    += 1
            sender    = random_account
            recipient = random_account
            amountNQT = rand(MAX_GIVEAWAY_AMOUNT_NQT)
            sendmoney(sender, recipient, amountNQT)   
          end
        end
      end
    end
    
    def random_account
      Account.order("RANDOM()").first
    end
    
    def get_account(native_id)
      Account.where(:native_id => native_id).first_or_create
    end
    
    def sendmoney(sender, recipient, amountNQT, feeNQT=1*ONE_NXT) 
      PendingTransaction.create({
        :sender     => sender,
        :recipient  => recipient,
        :amount_nqt => amountNQT,
        :fee_nqt    => feeNQT
      })
    end    
  end
end