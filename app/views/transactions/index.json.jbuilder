json.array!(@transactions) do |transaction|
  json.extract! transaction, :id, :block_id, :native_id, :amount_nqt, :fee_nqt, :sender_id, :recipient_id
  json.url transaction_url(transaction, format: :json)
end
