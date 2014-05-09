require 'rake'
require 'nxt'

namespace :backgroundjob do
  
  # Adds all Accounts to the database
  task generate_accounts: :environment  do
    NXT::AccountGenerator.new.perform
  end
  
  # Polls the nxt node for new blocks
  task :poll_blocks, [:interval] => [:environment]  do |t, args|
    NXT::Runner.new(:poll_blocks).perform do
      NXT::BlockPoller.new.perform(args[:interval])
    end
  end
  
    # Polls the nxt node for new blocks
  task :poll_transactions, [:interval] => [:environment]  do |t, args|
    NXT::Runner.new(:poll_transactions).perform do
      NXT::TransactionPoller.new.perform(args[:interval])
    end
  end
  
  # Sends 1 random Transaction
  task :send_transaction, [:interval] => [:environment]  do |t, args|
    NXT::Runner.new(:send_transaction).perform do
      NXT::TransactionSender.new.perform(args[:interval])
    end
  end
    
end