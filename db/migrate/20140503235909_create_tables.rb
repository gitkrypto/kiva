class CreateTables < ActiveRecord::Migration
  def change
    
    create_table :accounts do |t|
      t.string      :native_id
      t.integer     :balance_nqt,         limit: 8, unsigned: true, null: true
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
      t.integer     :total_amount_nqt,    limit: 8, unsigned: true, null: true
      t.integer     :total_fee_nqt,       limit: 8, unsigned: true, null: true
      t.integer     :total_pos_nqt,       limit: 8, unsigned: true, null: true
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
      t.integer     :amount_nqt,          limit: 8, unsigned: true, null: true
      t.integer     :fee_nqt,             limit: 8, unsigned: true, null: true
    end      
  end
end

