class Address < ApplicationRecord
  has_many :objekts
  has_many :people
end
