require 'rufus-scheduler'
require 'nxt'

scheduler   = Rufus::Scheduler.new
commander   = NXT::Commander.new

scheduler.every '100s' do
  # Disabled
  #commander.poll
end