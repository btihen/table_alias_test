class CreateObjekts < ActiveRecord::Migration[7.0]
  def change
    create_table :objekts do |t|
      t.references :address, null: false, foreign_key: true
      t.references :owner, null: false, foreign_key: { to_table: :people }

      t.timestamps
    end
  end
end
