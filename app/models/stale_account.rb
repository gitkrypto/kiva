class StaleAccount < ActiveRecord::Base
  belongs_to    :stale,    :class_name => "Account", :foreign_key => "stale"
end
