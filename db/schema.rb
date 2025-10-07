# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_11_230623) do
  create_table "devices", force: :cascade do |t|
    t.string "external_id"
    t.string "description"
    t.string "ip_address"
    t.string "encrypted_key"
    t.float "expiry_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_devices_on_external_id"
  end

  create_table "metrics", force: :cascade do |t|
    t.integer "sensor_id"
    t.float "timestamp"
    t.float "value"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sensor_id"], name: "index_metrics_on_sensor_id"
  end

  create_table "sensors", force: :cascade do |t|
    t.string "external_id"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "device_id", null: false
    t.index ["device_id"], name: "index_sensors_on_device_id"
    t.index ["external_id"], name: "index_sensors_on_external_id"
    t.index ["type"], name: "index_sensors_on_type"
  end

  add_foreign_key "metrics", "sensors"
  add_foreign_key "sensors", "devices"
end
