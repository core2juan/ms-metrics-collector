# frozen_string_literal: true

FactoryBot.define do
  factory :sensor do
    sequence(:external_id) { |n| "sensor_#{n}" }
    type { "Sensors::FloatSensor" }
    device

    trait :energy_consumption do
      type { "Sensors::EnergyConsumptionSensor" }
    end

    trait :with_metrics do
      transient do
        metric_count { 3 }
      end

      after(:create) do |sensor, evaluator|
        create_list(:metric, evaluator.metric_count, sensor: sensor)
      end
    end
  end

  factory :float_sensor, parent: :sensor, class: "Sensors::FloatSensor" do
    type { "Sensors::FloatSensor" }
  end

  factory :energy_consumption_sensor, parent: :sensor, class: "Sensors::EnergyConsumptionSensor" do
    type { "Sensors::EnergyConsumptionSensor" }
  end
end
