class Block < ActiveRecord::Base 
  belongs_to      :generator,       :class_name => "Account", :foreign_key => "generator"
  has_many        :transactions
  belongs_to      :next_block,      :class_name => "Block", :foreign_key => "next_block"
  belongs_to      :previous_block,  :class_name => "Block", :foreign_key => "previous_block"
end
