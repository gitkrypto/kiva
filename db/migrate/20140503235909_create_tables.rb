class CreateTables < ActiveRecord::Migration
  def change
    
    create_table :accounts do |t|
      t.string      :native_id
      t.decimal     :balance_nqt,           :precision => 20, :scale => 0, :default => 0
      t.decimal     :pos_balance_nqt,       :precision => 20, :scale => 0, :default => 0
      t.string      :public_key
      t.string      :passphrase
    end    
    add_index :accounts, :native_id
    
    create_table :blocks do |t|
      t.string      :native_id
      t.integer     :generator              # generator account
      t.integer     :timestamp,             default: 0
      t.integer     :height
      t.integer     :payload_length,        default: 0
      t.string      :payload_hash
      t.string      :generation_signature
      t.string      :block_signature
      t.decimal     :base_target,           :precision => 20, :scale => 0, :default => 0
      t.decimal     :cumulative_difficulty, :precision => 20, :scale => 0, :default => 0
      t.decimal     :total_amount_nqt,      :precision => 20, :scale => 0, :default => 0
      t.decimal     :total_fee_nqt,         :precision => 20, :scale => 0, :default => 0
      t.decimal     :total_pos_nqt,         :precision => 20, :scale => 0, :default => 0
      t.integer     :version
      t.integer     :previous_block         # foreign key to blocks
      t.integer     :next_block             # foreign key to blocks
    end    
    add_index :blocks, :generator
    add_index :blocks, :height
    add_index :blocks, :native_id

    create_table :transactions do |t|
      t.string      :native_id
      t.integer     :timestamp,             default: 0
      t.integer     :block                  # foreign key to blocks
      t.integer     :sender                 # foreign key to accounts
      t.integer     :recipient              # foreign key to accounts
      t.decimal     :amount_nqt,            :precision => 20, :scale => 0, :default => 0
      t.decimal     :fee_nqt,               :precision => 20, :scale => 0, :default => 0
    end
    add_index :transactions, :native_id
    add_index :transactions, :block
    add_index :transactions, :sender
    add_index :transactions, :recipient
    
    create_table :pending_transactions do |t|
      t.timestamps
      t.integer     :sender                 # foreign key to accounts
      t.integer     :recipient              # foreign key to accounts
      t.decimal     :amount_nqt,            :precision => 20, :scale => 0, :default => 0
      t.decimal     :fee_nqt,               :precision => 20, :scale => 0, :default => 0
      t.string      :native_id
      t.string      :error_msg
      t.integer     :error_code
    end
    add_index :pending_transactions, :sender
    add_index :pending_transactions, :recipient
    add_index :pending_transactions, :native_id
    
    create_table :unconfirmed_transactions do |t|
      t.integer     :sender                 # foreign key to accounts
      t.integer     :recipient              # foreign key to accounts
      t.decimal     :amount_nqt,            :precision => 20, :scale => 0, :default => 0
      t.decimal     :fee_nqt,               :precision => 20, :scale => 0, :default => 0
      t.string      :native_id
      t.integer     :timestamp,             default: 0
    end
    
    
    add_index :unconfirmed_transactions, :sender
    add_index :unconfirmed_transactions, :recipient
    add_index :unconfirmed_transactions, :native_id   
    
  end
end

