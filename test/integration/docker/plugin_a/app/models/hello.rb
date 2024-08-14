class Hello < (defined?(ApplicationRecord) ? ApplicationRecord : ActiveRecord::Base)
end
