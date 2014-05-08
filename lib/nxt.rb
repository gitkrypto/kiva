require 'rest_client'
require 'json'
require 'csv'

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
end

require 'nxt/api'
require 'nxt/block_poller'
require 'nxt/transaction_sender'
require 'nxt/runner'
require 'nxt/genesis'