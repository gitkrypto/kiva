require 'rufus-scheduler'
require 'nxt'

scheduler   = Rufus::Scheduler.new
commander   = NXT::Commander.new

scheduler.every '5s' do
  commander.poll
end