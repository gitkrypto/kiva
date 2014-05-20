require 'rake'
require 'nxt'

namespace :backgroundjob do
  
  # Polls the nxt node for new blocks
  task :poll_blocks, [:interval] => [:environment]  do |t, args|
    NXT::BlockPoller.new.perform(args[:interval])
  end
  
    # Polls the nxt node for new blocks
  task :poll_transactions, [:interval] => [:environment]  do |t, args|
    NXT::TransactionPoller.new.perform(args[:interval])
  end
  
  # Sends 1 random Transaction
  task :send_transaction, [:interval] => [:environment]  do |t, args|
    NXT::TransactionSender.new.perform(args[:interval])
  end
    
  # Iterate all Accounts and update their passphrase field
  task :seed_accounts => :environment do 
    add_stakeholder_accounts
    add_csv_accounts
  end
  
  # Generate all Stakeholder accounts
  def add_stakeholder_accounts
    puts "Generating Stakeholder Accounts"
    ActiveRecord::Base.transaction do
      accounts  = Fuzzer::Genesis.accounts
      accounts  = accounts.slice(0..20) if Rails.env != 'production'      
      accounts.each_with_index do |native_id, index| 
        puts "Adding Stakeholder Account #{index} ... '#{native_id}' - '#{Fuzzer::Genesis.keys[index]}'" if index % 100 == 0
        begin
          acc   = Account.find_or_initialize_by(native_id: native_id) do |account|
            account.passphrase = Fuzzer::Genesis.keys[index]
          end
          acc.save!
        rescue ActiveRecord::RecordNotUnique
          retry
        end
      end
    end
  end
  
  # Generate all accounts in the accounts.csv monster list
  def add_csv_accounts
    puts "Generating Accounts From accounts.csv"
    count    = 0
    accounts = CSV.read("#{Rails.root}/lib/nxt/accounts.csv")
    accounts = accounts.slice(0..600) if Rails.env != 'production'  
    accounts.each_slice(100) do |arr|
      puts "Adding Account #{count} ..." if count % 100 == 0
      ActiveRecord::Base.transaction do
        arr.each do |row|
          count      += 1
          native_id   = row[0]
          native_id.strip!
          passphrase  = row[1]
          passphrase.strip!
          begin          
            acc       = Account.find_or_initialize_by(native_id: native_id) do |account|
              account.passphrase = passphrase
            end
            acc.save!    
          rescue ActiveRecord::RecordNotUnique
            retry
          end
        end
      end
    end
  end
  
end