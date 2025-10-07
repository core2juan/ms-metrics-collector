class CreateMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :metrics do |t|
      t.references :sensor, foreign_key: { to_table: :sensors }
      t.float :timestamp
      t.float :value
      t.string :description

      t.timestamps
    end
  end
end
