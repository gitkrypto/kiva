class Account < ActiveRecord::Base
  has_many        :blocks
end
