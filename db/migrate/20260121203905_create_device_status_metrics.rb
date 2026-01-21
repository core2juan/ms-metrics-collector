class CreateDeviceStatusMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :device_status_metrics do |t|
      t.references :device, null: false, foreign_key: true
      t.json :metrics, null: false, default: {}
      t.float :timestamp, null: false

      t.timestamps
    end

    add_index :device_status_metrics, :timestamp
    add_index :device_status_metrics, [:device_id, :timestamp]
  end
end
