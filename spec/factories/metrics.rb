# frozen_string_literal: true

FactoryBot.define do
  factory :metric do
    sensor
    timestamp { Time.current.to_f }
    value { rand(0.0..100.0).round(2) }
    description { "FloatSensor: Test metric reading" }

    trait :energy_reading do
      description { "EnergyConsumptionSensor: Energy consumption reading" }
      value { rand(100.0..500.0).round(2) }
    end
  end
end
