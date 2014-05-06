module NXT
  class Commander
    
    def initialize
      @api    = API.new(nxtnode_host, 7886)
      @height = 0
    end
    
    def nxtnode_host
      @nxtnode_host ||= begin
        path = "/home/deploy/nxt.json"
        if File.exists? path
          JSON.parse(File.open(path, "rb").read)['nodes'].first  
        else
          '95.85.30.207'
        end
      end
    end
    
    def poll
      ActiveRecord::Base.transaction do
        poll_internal
      end
    end    
    
    # Always go back 50 blocks from the current height in order to find forks 
    def poll_internal
      
      logger.info "###############################################################################"
      logger.info "HELLO"
      logger.info "###############################################################################"
      logger.flush
      
      response    = @api.getBlocksIdsFromHeight([0, @height-50].max)
      fromHeight  = response['fromHeight']
      ids         = response['blockIds']
      return unless ids
        
      # Scan the returned ids and remove orphaned blocks
      ids.each_with_index do |id, index|
        height    = index + fromHeight
        block     = Block.where(:height => height).first
        break unless block
        
        unless block.native_id == id
          block.destroy
          
          # TODO remove all transactions          
        end
      end 
        
      # Scan it again, now add anything that is not yet in the db
      ids.each_with_index do |id, index|
        height      = index + fromHeight 
        block       = Block.where(:native_id => id).first
        next if block
        
        # New block found
        json        = @api.getBlock(id)
        
        # Lookup other db objects
        account     = Account.where(:native_id => json['generator']).first_or_create
        next_block  = Block.where(:native_id => json['nextBlock']).first
        prev_block  = Block.where(:native_id => json['previousBlock']).first
        
        # Create a new db block
        block       = Block.create!({ 
          :native_id        => id,
          :account          => account,
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
          :previous_block   => prev_block,
          :next_block       => next_block
        })
        
        # Lookup all transactions
        transactions  = json['transactions']
        transactions.each do |txn_id|
          json        = @api.getTransaction(txn_id)
          
          # Create a new transaction
          transaction = Transaction.create({
            :native_id        => txn_id,
            :timestamp        => json['timestamp'],
            :block            => block,
            :sender           => Account.where(:native_id => json['sender']).first_or_create,
            :recipient        => Account.where(:native_id => json['recipient']).first_or_create,
            :amount_nqt       => json['amountNQT'],
            :fee_nqt          => json['fee_nqt']
          })
        end
      end      
    end
  end
end