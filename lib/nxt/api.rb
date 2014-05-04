module NXT
  class API
  
    def initialize(host, port)
      @url  = "http://#{host}:#{port}/nxt"
    end
  
    def get(requestType, params={}) 
      params['requestType'] = requestType
      json = RestClient.get @url, {:params => params, :timeout => 10, :open_timeout => 10}
      obj = JSON.parse json
      puts json
      obj
    end
    
    def getBlocksIdsFromHeight(fromHeight=0, toHeight=10)
      get(:getBlocksIdsFromHeight, fromHeight: fromHeight, toHeight: toHeight)
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
  end
end