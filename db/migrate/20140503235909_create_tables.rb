class CreateTables < ActiveRecord::Migration
  def change
    
    create_table :accounts do |t|
      t.string      :native_id
      t.decimal     :balance_nqt,         :precision => 30, :scale => 0
      t.string      :public_key
    end
    
    create_table :blocks do |t|
      t.string      :native_id
      t.belongs_to  :account              # generator account
      t.integer     :timestamp
      t.integer     :height
      t.integer     :payload_length
      t.string      :payload_hash
      t.string      :generation_signature
      t.string      :block_signature
      t.decimal     :base_target
      t.decimal     :cumulative_difficulty
      t.decimal     :total_amount_nqt,    :precision => 30, :scale => 0
      t.decimal     :total_fee_nqt,       :precision => 30, :scale => 0
      t.decimal     :total_pos_nqt,       :precision => 30, :scale => 0
      t.integer     :version
      t.integer     :previous_block       # foreign key to blocks
      t.integer     :next_block           # foreign key to blocks
    end

    create_table :transactions do |t|
      t.string      :native_id
      t.integer     :timestamp
      t.belongs_to  :block  
      t.integer     :sender               # foreign key to accounts
      t.integer     :recipient            # foreign key to accounts
      t.decimal     :amount_nqt,          :precision => 30, :scale => 0
      t.decimal     :fee_nqt,             :precision => 30, :scale => 0
    end      
  end
end

