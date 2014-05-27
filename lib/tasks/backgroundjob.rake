require 'rake'
require 'nxt'

namespace :backgroundjob do
  
  # Polls the nxt node for new blocks
  task :poll_blocks, [:interval] => [:environment]  do |t, args|
    interval = args[:interval] || 5
    NXT::BlockPoller.new.perform(interval)
  end
  
    # Polls the nxt node for new blocks
  task :poll_transactions, [:interval] => [:environment]  do |t, args|
    interval = args[:interval] || 2    
    NXT::TransactionPoller.new.perform(interval)
  end
  
  # Sends 1 random Transaction
  task :send_transaction, [:interval] => [:environment]  do |t, args|
    interval = args[:interval] || 2
    NXT::TransactionSender.new.perform(interval)
  end
    
  # Iterate all Accounts and update their passphrase field
  task :seed_accounts => :environment do 
    add_stakeholder_accounts
    add_csv_accounts
  end
  
  # Generate all Stakeholder accounts
  def add_stakeholder_accounts
    puts "Generating Stakeholder Accounts"
    count    = 0
    accounts = CSV.read("#{Rails.root}/lib/nxt/test_net_keys.csv")
    accounts.each_slice(100) do |arr|
      ActiveRecord::Base.transaction do
        arr.each do |row|
          count      += 1
          native_id   = row[1]
          native_id.strip!
          passphrase  = row[3]
          passphrase.strip!
          puts "Adding Stakeholder Account #{count} #{native_id} ..." if count % 100 == 0
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
  
  # Generate all accounts in the accounts.csv monster list
  def add_csv_accounts
    puts "Generating Accounts From accounts.csv"
    count    = 0
    accounts = CSV.read("#{Rails.root}/lib/nxt/accounts.csv")
    #accounts = accounts.slice(0..600) if Rails.env != 'production'  
    accounts.each_slice(100) do |arr|
      ActiveRecord::Base.transaction do
        arr.each do |row|
          count      += 1
          native_id   = row[0]
          native_id.strip!
          passphrase  = row[1]
          passphrase.strip!
          puts "Adding Account #{count} #{native_id} ..." if count % 100 == 0
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