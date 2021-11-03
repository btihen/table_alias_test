class Person < ApplicationRecord
  belongs_to :address
  belongs_to :language
  has_many :leases
  has_many :appartments, class_name: 'Objekt'
end
