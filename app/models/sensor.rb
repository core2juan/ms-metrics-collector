class Sensor < ApplicationRecord
  belongs_to :device
  has_many :metrics, dependent: :destroy

  validates :external_id, presence: true, uniqueness: { scope: :type }
  validates :type, presence: true
end
