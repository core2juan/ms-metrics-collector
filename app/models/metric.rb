class Metric < ApplicationRecord
  belongs_to :sensor

  validates :timestamp, presence: true
  validates :value, presence: true
end
