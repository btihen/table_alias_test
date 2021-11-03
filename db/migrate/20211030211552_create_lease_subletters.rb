class CreateLeaseSubletters < ActiveRecord::Migration[7.0]
  def change
    create_table :lease_subletters do |t|
      t.references :lease, null: false, foreign_key: true
      t.references :subletter, null: false, foreign_key: { to_table: :people }

      t.timestamps
    end
  end
end
