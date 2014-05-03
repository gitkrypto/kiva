class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|
      t.integer :height
      t.string :generator_id
      t.decimal :total_amount_nqt
      t.decimal :total_fee_nqt
      t.decimal :total_pos_reward_nqt

      t.timestamps
    end
  end
end
