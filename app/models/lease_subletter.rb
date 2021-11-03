class LeaseSubletter < ApplicationRecord
  belongs_to :lease
  belongs_to :subletter, class_name: 'Person'
end
