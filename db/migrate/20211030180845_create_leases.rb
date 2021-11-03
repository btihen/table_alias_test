class CreateLeases < ActiveRecord::Migration[7.0]
  def change
    create_table :leases do |t|
      t.references :objekt, null: false, foreign_key: true
      t.references :prior_lease, foreign_key: { to_table: :leases }
      t.references :renter, null: false, foreign_key: { to_table: :people }

      t.timestamps
    end
  end
end
