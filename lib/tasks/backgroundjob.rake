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
    
end