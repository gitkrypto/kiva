json.array!(@blocks) do |block|
  json.extract! block, :id, :height, :generator_id, :total_amount_nqt, :total_fee_nqt, :total_pos_reward_nqt
  json.url block_url(block, format: :json)
end
