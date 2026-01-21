# frozen_string_literal: true

FactoryBot.define do
  factory :device do
    sequence(:external_id) { |n| "device_#{n}" }
    description { "Test Device" }
    ip_address { "192.168.1.100" }

    trait :expired do
      after(:create) do |device|
        device.update_column(:expiry_time, 1.day.ago.to_f)
      end
    end

    trait :with_sensors do
      transient do
        sensor_count { 2 }
      end

      after(:create) do |device, evaluator|
        create_list(:sensor, evaluator.sensor_count, device: device)
      end
    end
  end
end
