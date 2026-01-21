# frozen_string_literal: true

FactoryBot.define do
  factory :device_status_metric do
    device
    timestamp { Time.current.to_f }
    metrics do
      {
        cpu_usage: rand(0.0..100.0).round(2),
        memory_usage: rand(0.0..100.0).round(2),
        temperature: rand(30.0..90.0).round(2)
      }
    end

    trait :with_full_metrics do
      metrics do
        {
          cpu_usage: rand(0.0..100.0).round(2),
          memory_usage: rand(0.0..100.0).round(2),
          temperature: rand(30.0..90.0).round(2),
          disk_usage: rand(0.0..100.0).round(2),
          network_rx_bytes: rand(1000..1000000),
          network_tx_bytes: rand(1000..1000000)
        }
      end
    end

    trait :historical do
      timestamp { rand(1..7).days.ago.to_f }
    end
  end
end
