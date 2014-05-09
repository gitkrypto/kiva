# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'securerandom'

def generate_id
  rand(10000000000000000..10000000000000000000000).to_s
end

def generate_hash
  SecureRandom.hex
end

ONE_NXT = 10000000

ActiveRecord::Base.transaction do
  accounts    = []
  timestamp   = 0
  prev_block  = nil
  
  # Generate 30 Accounts
  90.times do 
    accounts << Account.create({ 
      :native_id              => generate_id,
      :balance_nqt            => rand(ONE_NXT..ONE_NXT * 1000000),
      :public_key             => generate_hash
    })     
  end
  
  # Generate 100 blocks
  100.times do |height|

    total_amount  = 0
    total_fee     = 0
    total_pos     = 100 * ONE_NXT    
    
    block = Block.create({
      :native_id              => generate_id,
      :timestamp              => timestamp,
      :height                 => height, 
      :account                => accounts.sample, 
      :payload_length         => 10,
      :payload_hash           => generate_hash,
      :generation_signature   => generate_hash,
      :block_signature        => generate_hash,
      :base_target            => rand(100..10000),
      :cumulative_difficulty  => rand(10000..10000000),
      :version                => 3
    })
    
    if prev_block
      prev_block.next_block     = block 
      prev_block.save
    end
    
    block.previous_block      = prev_block if prev_block
    prev_block                = block
    block.save    

    # Generate between 0 and 255 transactions
    rand(0..255).times do 
      amount          = rand(1..100000000 * ONE_NXT)
      total_amount   += amount
      fee             = rand(ONE_NXT..ONE_NXT * 100)
      total_fee      += fee

      transaction     = Transaction.create({ 
        :native_id          => generate_id, 
        :timestamp          => timestamp+=1,
        :amount_nqt         => amount, 
        :fee_nqt            => fee,
        :sender             => accounts.sample,
        :recipient          => accounts.sample,
        :block              => block
      })
    end

    block.total_amount_nqt  = total_amount
    block.total_fee_nqt     = total_fee
    block.total_pos_nqt     = total_pos
    block.save
  end
end