require 'rufus-scheduler'
require 'nxt'

scheduler   = Rufus::Scheduler.new
commander   = NXT::Commander.new

scheduler.every '15s' do
  commander.poll
end