module NXT

  class BlockPoller    
    def perform(interval)
      begin
        loop do
          opts = get_new_blocks
          if opts[:blockIds]
            remove_orphaned_blocks(opts)
            add_new_blocks(opts)
          end
          puts "Going to sleep ... #{interval} seconds" if NXT.verbose
          sleep interval.to_i
        end
      rescue => e
        log("Error: #{$!}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
        throw e
      end
    end
    
    def log(msg)
      NXT.log('block poller', msg)
    end

    # { blockIds: [], fromHeight: 1 }
    def get_new_blocks
      fromHeight = [0, current_height-50].max
      toHeight   = fromHeight + 100
      response   = NXT::api.getBlocksIdsFromHeight(fromHeight, toHeight)
      return {} if NXT.is_error(response)
      {
        blockIds:   response['blockIds'],
        fromHeight: response['fromHeight']
      }
    end

    # Scan blockIds, all new blocks and their transactions are added
    # @param opts { blockIds: [], fromHeight: 1 }
    def add_new_blocks(opts)
      opts[:blockIds].each_with_index do |native_id, index|
        download_block(native_id) unless get_block(native_id)
      end
    end

    # Add the account to StaleAccount
    def add_affected_account(native_id)
      StaleAccount.where(:native_id => native_id).first_or_create
    end

    # Downloads and stores a Block
    def download_block(native_id)
      json = NXT::api.getBlock(native_id)
      return if NXT.is_error(json) || !json['transactions']

      prev_block  = get_block(json['previousBlock'])

      generator = get_account(json['generator'], json['generatorRS'], json['height'])
      throw "No generator block=#{native_id}" unless generator
      add_affected_account(json['generator'])

      # Create a new db block
      block       = Block.create!({
        :native_id        => native_id,
        :generator        => generator,
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

      # Downloads and stores all Transactions
      json['transactions'].each do |native_transaction_id|
        download_transaction(native_transaction_id, block)
      end
    end

    # Downloads and stores a Transaction
    def download_transaction(native_id, block)
      json = NXT::api.getTransaction(native_id)
      return if NXT.is_error(json)

      sender      = get_account(json['sender'], json['senderRS'], block.height)
      recipient   = get_account(json['recipient'], json['recipientRS'], block.height)

      throw "No sender txn=#{native_id} block=#{block.native_id}" unless sender
      throw "No recipient txn=#{native_id} block=#{block.native_id}" unless recipient

      ActiveRecord::Base.transaction do

        # Add both sender and recipient to affected_accounts so they can be obtained later
        add_affected_account(json['sender'])
        add_affected_account(json['recipient'])

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

        if NXT.is_alias(transaction) 
          attributes = {
            :alias          => json['attachment']['alias'],
            :uri            => json['attachment']['uri'],
            :txn            => transaction,
            :owner          => sender,
            :block          => block            
          }
          _alias = Alias.find_or_create_by(:alias => json['attachment']['alias'])
          _alias.update(attributes)
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

            # Add block generator to affected_accounts
            add_affected_account(block.generator_id)

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
              Transaction.where(:block => block).find_each do |t|
                # Add both sender and recipient to affected_accounts so they can be obtained later
                add_affected_account(t.recipient_id)
                add_affected_account(t.sender_id)
               end
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

  end
end