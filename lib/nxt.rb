require 'rest_client'
require 'json'
require 'csv'
require 'cgi'

module NXT
  ONE_NXT = 100000000
  DEBUG   = true
  
  def self.api
    @@api ||= begin
      path = "/home/deploy/nxt.json"
      host = if File.exists? path
        JSON.parse(File.open(path, "rb").read)['nodes'].first
      else
        '95.85.30.207'
      end
      API.new(host, 7886)
    end
  end
  
  # "http://95.85.30.207:7886/nxt?secretPhrase=mania+lessee+leapt+31+cy+coat+nimh+puppy+ys+butt+defy+bandit&recipient=11047499023811727519&amountNQT=49776892677179&feeNQT=100000000&deadline=1440&referencedTransaction=&requestType=sendMoney"
  
  def self.log(sender, msg)
    puts "#{Time.now} [#{sender}] #{msg}"
  end
end

require 'nxt/api'
require 'nxt/block_poller'
require 'nxt/transaction_sender'
require 'nxt/runner'
require 'nxt/genesis'