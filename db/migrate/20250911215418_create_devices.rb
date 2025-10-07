class CreateDevices < ActiveRecord::Migration[8.0]
  def change
    create_table :devices do |t|
      t.string :external_id
      t.string :description
      t.string :ip_address
      t.string :encrypted_key
      t.float :expiry_time

      t.timestamps
    end
    add_index :devices, :external_id
  end
end
