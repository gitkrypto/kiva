module NXT
  class BlockPoller    
    def perform(interval)
      loop do
        opts = get_new_blocks
        if opts[:blockIds]
          remove_orphaned_blocks opts
          add_new_blocks opts
        end
        puts "Going to sleep ... #{interval} seconds"
        sleep interval.to_i
      end
    end

    # { blockIds: [], fromHeight: 1 }
    def get_new_blocks
      fromHeight = [0, current_height-50].max
      toHeight   = fromHeight + 100
      response   = NXT::api.getBlocksIdsFromHeight(fromHeight, toHeight)
      {
        blockIds:   response['blockIds'],
        fromHeight: response['fromHeight']
      }
    end

    # Scans blockIds and remove orphaned blocks
    # @param opts { blockIds: [], fromHeight: 1 }
    def remove_orphaned_blocks(opts)
      ActiveRecord::Base.transaction do
        opts[:blockIds].each_with_index do |native_id, index|
          height = index + opts[:fromHeight]
          block  = Block.where(:height => height).first
          next unless block        
          if block.native_id != native_id
            undo(block)          
            Transaction.where(:block => block).delete_all
            Block.delete(block)
          end
        end
      end
    end

    # Scan blockIds, all new blocks and their transactions are added
    # @param opts { blockIds: [], fromHeight: 1 }
    def add_new_blocks(opts)
      opts[:blockIds].each_with_index do |native_id, index|
        download_block(native_id) unless get_block(native_id)
      end
    end

    # Downloads and stores a Block
    def download_block(native_id)
      json = NXT::api.getBlock(native_id)
      prev_block  = get_block(json['previousBlock'])

      # Create a new db block
      block       = Block.create!({
        :native_id        => native_id,
        :generator        => get_account(json['generator']),
        :timestamp        => json['timestamp'],
        :height           => json['height'],
        :payload_length   => json['payloadLength'],
        :payload_hash     => json['payloadHash'],
        :generation_signature => json['generationSignature'],
        :block_signature  => json['blockSignature'],
        :base_target      => json['baseTarget'],
        :cumulative_difficulty => json['cumulativeDifficulty'],
        :total_amount_nqt => json['totalAmountNQT'],
        :total_fee_nqt    => json['totalFeeNQT'],
        :total_pos_nqt    => json['totalPOSRewardNQT'],
        :version          => json['version'],
        :previous_block   => prev_block
      })

      if prev_block
        prev_block.next_block = block
        prev_block.save
      end

      json['transactions'].each do |native_transaction_id|
        download_transaction(native_transaction_id, block)
      end
      
      apply(block)
    end

    # Downloads and stores a Transaction
    def download_transaction(native_id, block)
      json = NXT::api.getTransaction(native_id)
      ActiveRecord::Base.transaction do
        transaction = Transaction.create({
          :native_id        => native_id,
          :timestamp        => json['timestamp'],
          :block            => block,
          :sender           => get_account(json['sender']),
          :recipient        => get_account(json['recipient']),
          :amount_nqt       => json['amountNQT'],
          :fee_nqt          => json['feeNQT']
        })
        UnconfirmedTransaction.where(:native_id => native_id).delete_all
      end
    end
    
    def logger
      Rails.logger
    end

    def current_height
      Block.order('height DESC').first.height rescue 0
    end

    def get_account(native_id)
      Account.where(:native_id => native_id).first_or_create
    end

    def get_block(native_id)
      Block.where(:native_id => native_id).first
    end
    
    def apply(block)
      ActiveRecord::Base.transaction do
        block.generator.balance_nqt     += block.total_pos_nqt + block.total_fee_nqt
        block.generator.pos_balance_nqt += block.total_pos_nqt
        block.generator.save
        
        Transaction.where(block: block).each do |t|
          t.sender.balance_nqt    -= t.amount_nqt + t.fee_nqt
          t.recipient.balance_nqt += t.amount_nqt
          t.sender.save
          t.recipient.save          
        end        
      end
    end
    
    def undo(block)
      ActiveRecord::Base.transaction do
        block.generator.balance_nqt     -= block.total_pos_nqt + block.total_fee_nqt
        block.generator.pos_balance_nqt -= block.total_pos_nqt
        block.generator.save
        
        Transaction.where(block: block).each do |t|
          t.sender.balance_nqt    += t.amount_nqt + t.fee_nqt
          t.recipient.balance_nqt -= t.amount_nqt
          t.sender.save
          t.recipient.save          
        end        
      end
    end
  end
end