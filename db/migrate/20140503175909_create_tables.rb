class CreateTables < ActiveRecord::Migration
  def change
    
    create_table :accounts do |t|
      t.string      :native_id
      t.column      :balance_nqt,         :integer, :limit => 8, :precision => :unsigned, :scale => 0
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
      t.column      :total_amount_nqt,    :integer, :limit => 8, :precision => :unsigned, :scale => 0
      t.column      :total_fee_nqt,       :integer, :limit => 8, :precision => :unsigned, :scale => 0
      t.column      :total_pos_nqt,       :integer, :limit => 8, :precision => :unsigned, :scale => 0
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
      t.column      :amount_nqt,          :integer, :limit => 8, :precision => :unsigned, :scale => 0
      t.column      :fee_nqt,             :integer, :limit => 8, :precision => :unsigned, :scale => 0
    end      
  end
end

