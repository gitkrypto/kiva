class Alias < ActiveRecord::Base
  belongs_to    :txn,       :class_name => "Transaction", :foreign_key => "txn"
  belongs_to    :owner,     :class_name => "Account", :foreign_key => "owner"
end