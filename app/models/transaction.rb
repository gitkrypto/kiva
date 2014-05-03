class Transaction < ActiveRecord::Base
  belongs_to :block
end
