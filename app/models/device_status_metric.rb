class DeviceStatusMetric < ApplicationRecord
  belongs_to :device

  validates :metrics, presence: true
  validates :timestamp, presence: true
end
