class Device < ApplicationRecord
  has_many :sensors, dependent: :destroy

  validates :external_id, presence: true, uniqueness: true
  validates :description, presence: true

  attr_accessor :plain_token

  TOKEN_EXPIRY = 30.days.to_i
  SALT = "monitoring_system_salt_2025"
  PEPPER = "monitoring_system_pepper_secure_2025"

  before_create :generate_and_encrypt_token

  def self.encrypt_token(token)
    Digest::SHA256.hexdigest("#{SALT}#{token}#{PEPPER}")
  end

  def token_expired?
    return true unless expiry_time
    Time.now.to_f > expiry_time
  end

  def refresh_token!
    self.plain_token = set_new_token
    save!
    plain_token
  end

  private

  def generate_token
    SecureRandom.hex(32)
  end

  def set_new_token
    token = generate_token
    self.encrypted_key = self.class.encrypt_token(token)
    self.expiry_time = Time.now.to_f + TOKEN_EXPIRY
    token
  end

  def generate_and_encrypt_token
    self.plain_token = set_new_token
  end
end
