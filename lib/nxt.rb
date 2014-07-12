require 'rest_client'
require 'json'
require 'csv'
require 'cgi'

module NXT
  ONE_NXT = 100000000
  MIN_FEE_NQT = 10000000
  DEBUG   = true

  TYPE_PAYMENT = 0
  TYPE_MESSAGING = 1
  TYPE_COLORED_COINS = 2
  TYPE_DIGITAL_GOODS = 3
  TYPE_ACCOUNT_CONTROL = 4

  SUBTYPE_PAYMENT_ORDINARY_PAYMENT = 0

  SUBTYPE_MESSAGING_ARBITRARY_MESSAGE = 0
  SUBTYPE_MESSAGING_ALIAS_ASSIGNMENT = 1
  SUBTYPE_MESSAGING_POLL_CREATION = 2
  SUBTYPE_MESSAGING_VOTE_CASTING = 3
  SUBTYPE_MESSAGING_HUB_ANNOUNCEMENT = 4
  SUBTYPE_MESSAGING_ACCOUNT_INFO = 5

  SUBTYPE_COLORED_COINS_ASSET_ISSUANCE = 0
  SUBTYPE_COLORED_COINS_ASSET_TRANSFER = 1
  SUBTYPE_COLORED_COINS_ASK_ORDER_PLACEMENT = 2
  SUBTYPE_COLORED_COINS_BID_ORDER_PLACEMENT = 3
  SUBTYPE_COLORED_COINS_ASK_ORDER_CANCELLATION = 4
  SUBTYPE_COLORED_COINS_BID_ORDER_CANCELLATION = 5

  SUBTYPE_DIGITAL_GOODS_LISTING = 0
  SUBTYPE_DIGITAL_GOODS_DELISTING = 1
  SUBTYPE_DIGITAL_GOODS_PRICE_CHANGE = 2
  SUBTYPE_DIGITAL_GOODS_QUANTITY_CHANGE = 3
  SUBTYPE_DIGITAL_GOODS_PURCHASE = 4
  SUBTYPE_DIGITAL_GOODS_DELIVERY = 5
  SUBTYPE_DIGITAL_GOODS_FEEDBACK = 6
  SUBTYPE_DIGITAL_GOODS_REFUND = 7  

  def self.verbose=(val)
    @@verbose = val
  end  
  
  def self.verbose
    @@verbose
  end
  
  def self.api
    @@api ||= begin
      path = "/home/deploy/fim.json"
      hosts =  [
        # vpx-1 512MB   20GB  ams2 - has accessible API
        '5.101.102.194',
        # vpx-2 512MB   20GB  ams2
        '5.101.102.195',
        # vpx-3 512MB   20GB  ams2
        '5.101.102.196',
        # vpx-3 512MB   20GB  ams2
        '5.101.102.197',
      ]
      API.new(hosts, 7886)
    end
  end
  
  # "http://95.85.30.207:7886/nxt?secretPhrase=mania+lessee+leapt+31+cy+coat+nimh+puppy+ys+butt+defy+bandit&recipient=11047499023811727519&amountNQT=49776892677179&feeNQT=100000000&deadline=1440&referencedTransaction=&requestType=sendMoney"
  
  def self.log(sender, msg)
    puts "#{Time.now} [#{sender}] #{msg}"
  end

  def self.is_error(response)
    response['errorCode'] || response['errorDescription'] || response['error']
  end    

  def self.is_alias(transaction)
    transaction.txn_type == TYPE_MESSAGING && transaction.txn_subtype == SUBTYPE_MESSAGING_ALIAS_ASSIGNMENT
  end
  
end

require 'nxt/api'
require 'nxt/block_poller'
require 'nxt/transaction_sender'