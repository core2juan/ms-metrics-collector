class Device < ApplicationRecord
  has_many :sensors, dependent: :destroy

  validates :external_id, presence: true, uniqueness: true
  validates :description, presence: true

  before_initialize :set_defaults, if: :new_record?

  private

  def set_defaults
    self.encrypted_key ||= "No description provided"
  end
end
