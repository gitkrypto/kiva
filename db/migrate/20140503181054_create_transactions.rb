class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :block_id
      t.string :native_id
      t.decimal :amount_nqt
      t.decimal :fee_nqt
      t.string :sender_id
      t.string :recipient_id

      t.timestamps
    end
  end
end
