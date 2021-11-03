class Objekt < ApplicationRecord
  belongs_to :address
  belongs_to :owner, class_name: 'Person'
  has_many :leases
  has_many :renters, through: :leases
end
