module NXT
  class API
    
    @verbose = false
  
    def initialize(host, port)
      @url  = "http://#{host}:#{port}/nxt"
    end
    
    # This is required since this class is run from an initializer
    def logger
      Rails.logger
    end
    
    def verbose=(val)
      @verbose = val
    end
  
    def get(requestType, params={}) 
      puts "INPUT => #{JSON.pretty_generate(params)}" if NXT.verbose
      params['requestType'] = requestType
      RestClient.log = $stdout  if NXT.verbose
      json = RestClient.get @url, {:params => params, :timeout => 10, :open_timeout => 10}
      obj = JSON.parse json
      puts "OUTPUT => #{JSON.pretty_generate(obj)}"  if NXT.verbose
      obj
    end
    
    def getBlocksIdsFromHeight(fromHeight=0, toHeight=10)
      get(:getBlocksIdsFromHeight, fromHeight: fromHeight, toHeight: toHeight)
    end
    
    # { unconfirmedTransactionIds: ["id1", "id2"] }
    def getUnconfirmedTransactionsIds
      get(:getUnconfirmedTransactionIds)
    end
    
    # height, generator, timestamp, numberOfTransactions, totalAmountNQT, totalFeeNQT, payloadLength
    # version, baseTarget, previousBlock, nextBlock, payloadHash, generationSignature, previousBlockHash
    # blockSignature, transactions, totalPOSRewardNQT, cumulativeDifficulty
    def getBlock(id)
      get(:getBlock, block: id)
    end    
    
    # type, subtype, timestamp, deadline, senderPublicKey, recipient, amountNQT,
    # feeNQT, referencedTransaction, referencedTransactionFullHash, signature, signatureHash,
    # fullHash, transaction, attachment, sender, hash, block, confirmations, blockTimestamp
    def getTransaction(id)
      get(:getTransaction, transaction: id)
    end
    
    # "TRANSACTIONID" 
    def sendMoney(secretPhrase, recipient, amountNQT, feeNQT=1*ONE_NXT, deadline=1440, referencedTransaction="")
      get("sendMoney", :secretPhrase => secretPhrase, :recipient => recipient, :amountNQT => amountNQT,
        :feeNQT => feeNQT, :deadline => deadline, :referencedTransaction => referencedTransaction)
    end
  end
end