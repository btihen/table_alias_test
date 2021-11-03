class Lease < ApplicationRecord
  belongs_to :objekt
  belongs_to :renter, class_name: 'Person'
  has_one :owner, through: :objekt
  # self-refertial
  belongs_to :prior_lease, class_name: "Lease", optional: true
  has_many :updated_leases, class_name: "Lease", foreign_key: "prior_lease_id"
  # join table
  has_many :lease_subletters
  has_many :subletters, through: :lease_subletters, class_name: 'Person'
end
