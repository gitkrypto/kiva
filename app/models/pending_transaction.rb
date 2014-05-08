class PendingTransaction < ActiveRecord::Base
  belongs_to    :sender,    :class_name => "Account", :foreign_key => "sender"
  belongs_to    :recipient, :class_name => "Account", :foreign_key => "recipient"
end
