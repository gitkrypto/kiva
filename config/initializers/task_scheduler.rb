require 'rufus-scheduler'
require 'nxt'

scheduler   = Rufus::Scheduler.new
commander   = NXT::Commander.new

Rails.logger.auto_flushing = true

scheduler.every '5s' do
  commander.poll
end