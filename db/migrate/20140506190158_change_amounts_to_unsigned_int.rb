class ChangeAmountsToUnsignedInt < ActiveRecord::Migration
  def change
    change_column :accounts, :balance_nqt, :decimal, :unsigned => true
    change_column :blocks, :total_amount_nqt, :decimal, :unsigned => true
    change_column :blocks, :total_fee_nqt, :decimal, :unsigned => true
    change_column :blocks, :total_pos_nqt, :decimal, :unsigned => true    
    change_column :transactions, :amount_nqt, :decimal, :unsigned => true
    change_column :transactions, :fee_nqt, :decimal, :unsigned => true
  end
end
