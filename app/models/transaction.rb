class Transaction < ActiveRecord::Base
  belongs_to    :block,     :class_name => "Block", :foreign_key => "block"
  belongs_to    :sender,    :class_name => "Account", :foreign_key => "sender"
  belongs_to    :recipient, :class_name => "Account", :foreign_key => "recipient"
end
