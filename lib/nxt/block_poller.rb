module NXT

  class BlockPoller    
    def perform(interval)
      begin
        loop do
          opts = get_new_blocks

          if opts[:blockIds]
            if remove_orphaned_blocks(opts)
              rescan
            end
            
            # Download all new blocks      
            opts[:blockIds].each_with_index do |native_id, index|
              download_block(native_id) unless get_block(native_id)
            end

          end
          puts "Going to sleep ... #{interval} seconds" if NXT.verbose
          sleep interval.to_i
        end
      rescue => e
        log("Error: #{$!}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
        throw e
      end
    end

    def is_error(response)
      response['errorCode'] || response['errorDescription']
    end
    
    def log(msg)
      NXT.log('block poller', msg)
    end

    # { blockIds: [], fromHeight: 1 }
    def get_new_blocks
      fromHeight = [0, current_height-50].max
      toHeight   = fromHeight + 100
      response   = NXT::api.getBlocksIdsFromHeight(fromHeight, toHeight)
      if is_error(response)
        {
          errorCode:  response['errorCode'],
          errorDescription:  response['errorDescription'],
        }
      else
        {
          blockIds:   response['blockIds'],
          fromHeight: response['fromHeight']
        }
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
        :generator        => get_account(json['generator'], json['generatorRS'], json['height']),
        :generator_id     => json['generator'],
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
        sender      = get_account(json['sender'], json['senderRS'], block.height)
        recipient   = get_account(json['recipient'], json['recipientRS'], block.height)

        throw "No sender txn=#{native_id} block=#{block.native_id}" unless sender
        throw "No recipient txn=#{native_id} block=#{block.native_id}" unless recipient

        transaction = Transaction.create!({
          :native_id        => native_id,
          :timestamp        => json['timestamp'],
          :block            => block,
          :sender           => sender,
          :recipient        => recipient,
          :sender_id        => json['sender'],
          :recipient_id     => json['recipient'],
          :amount_nqt       => json['amountNQT'],
          :fee_nqt          => json['feeNQT'],
          :txn_type         => json['type'],
          :txn_subtype      => json['subtype']
        })

        if is_alias(transaction) 
          Alias.create!({
            :alias          => json['attachment']['alias'],
            :uri            => json['attachment']['uri'],
            :txn            => transaction,
            :owner          => sender,
            :block          => block
          })
        end
      end
    end

    # Scans blockIds and removes orphaned blocks
    # @param opts { blockIds: [], fromHeight: 1 }
    # @returns true if an orphaned block was found
    def remove_orphaned_blocks(opts)
      ActiveRecord::Base.transaction do
        opts[:blockIds].each_with_index do |native_id, index|

          # The data in opts comes directly from the blockchain
          # If there is a block at that height already in the database we compare it's
          # native_id with the db version, if that does not match the native_id of the 
          # blockchain version we remove that block and all blocks after that from the 
          # database.

          height = index + opts[:fromHeight]
          block  = Block.where(:height => height).first
          next unless block

          if block.native_id != native_id

            # Selects all blocks starting at from_height and beyond
            blocks = Block.where('height >= ?', height).order('height ASC')

            # Unset the next_block property on the last good block
            last_good_block = blocks.first.previous_block rescue nil
            if last_good_block
              last_good_block.next_block = nil
              last_good_block.save
            end

            # Undo block then remove from Transaction and Block tables
            blocks.find_each do |block|
              Transaction.where(:block => block).delete_all
              Alias.where(:block => block).delete_all
            end
            blocks.delete_all
            return true
          end
        end
      end
      return false
    end

    def rescan
      log("Rescan start")
      Account.delete_all
      Alias.delete_all        
      Block.find_each do |block|
        ActiveRecord::Base.transaction do
          apply(block)
        end
      end
      log("Rescan complete")
    end
    
    def logger
      Rails.logger
    end

    def current_height
      Block.order('height DESC').first.height rescue 0
    end

    def get_account(native_id, native_id_rs, height)
      account = Account.where(:native_id => native_id, :native_id_rs => native_id_rs).first
      return account if account
      account = Account.create({
        :native_id    => native_id, 
        :native_id_rs => native_id_rs,
        :height       => height
      })
      account.save
      account
    end

    def get_block(native_id)
      Block.where(:native_id => native_id).first
    end
    
    def apply(block)
      unless block.generator 
        block.generator = get_account(block.generator_id, block.generator_id_rs, block.height)
      end

      block.generator.balance_nqt     += block.total_pos_nqt + block.total_fee_nqt
      block.generator.pos_balance_nqt += block.total_pos_nqt
      block.generator.save
    
      Transaction.where(block: block).each do |t|
        unless t.sender
          t.sender = get_account(t.sender_id, t.sender_id_rs, block.height)
        end

        unless t.recipient
          t.recipient = get_account(t.recipient_id, t.recipient_id_rs, block.height)
        end

        # Always deduct the fee, this works for all transactions
        t.sender.balance_nqt   -= t.fee_nqt
        t.sender.save

        if is_payment(t)
          t.sender.balance_nqt -= t.amount_nqt
          t.sender.save

          t.recipient.balance_nqt += t.amount_nqt 
          t.recipient.save
        end
      end 
    end

    def is_payment(transaction)
      transaction.txn_type == TYPE_PAYMENT && transaction.txn_subtype == SUBTYPE_PAYMENT_ORDINARY_PAYMENT
    end

    def is_alias(transaction)
      transaction.txn_type == TYPE_MESSAGING && transaction.txn_subtype == SUBTYPE_MESSAGING_ALIAS_ASSIGNMENT
    end
      
  end
end