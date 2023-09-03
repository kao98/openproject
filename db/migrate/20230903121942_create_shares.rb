class CreateShares < ActiveRecord::Migration[7.0]
  def change
    create_table :shares do |t|
      t.boolean :active, null: false, default: true
      t.references :parent, foreign_key: { to_table: :companies }
      t.references :child, foreign_key: { to_table: :companies }

      t.timestamps
    end
  end
end
