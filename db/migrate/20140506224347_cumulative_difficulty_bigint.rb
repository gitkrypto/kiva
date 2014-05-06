class CumulativeDifficultyBigint < ActiveRecord::Migration
  def change
    change_column :blocks, :base_target, :integer, limit: 8, unsigned: true, null: true
    change_column :blocks, :cumulative_difficulty, :integer, limit: 8, unsigned: true, null: true
  end
end
