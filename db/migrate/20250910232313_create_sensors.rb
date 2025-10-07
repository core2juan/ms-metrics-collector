class CreateSensors < ActiveRecord::Migration[8.0]
  def change
    create_table :sensors do |t|
      t.string :external_id
      t.string :type

      t.timestamps
    end
    add_index :sensors, :external_id
    add_index :sensors, :type
  end
end
