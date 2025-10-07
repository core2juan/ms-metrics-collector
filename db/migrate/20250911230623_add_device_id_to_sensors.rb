class AddDeviceIdToSensors < ActiveRecord::Migration[8.0]
  def change
    add_reference :sensors, :device, null: false, foreign_key: true
  end
end
