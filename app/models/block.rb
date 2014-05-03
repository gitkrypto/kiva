class Block < ActiveRecord::Base
  has_many :transactions
end
