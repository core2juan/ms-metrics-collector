# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Device do
  describe 'associations' do
    it { is_expected.to have_many(:sensors).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:device) }

    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_uniqueness_of(:external_id) }
  end

  describe 'callbacks' do
    describe 'before_create' do
      subject(:device) { build(:device) }

      it 'generates an encrypted token' do
        expect(device.encrypted_key).to be_nil
        device.save!
        expect(device.encrypted_key).to be_present
      end

      it 'sets expiry time' do
        device.save!
        expect(device.expiry_time).to be > Time.now.to_f
      end

      it 'exposes plain_token after creation' do
        device.save!
        expect(device.plain_token).to be_present
        expect(device.plain_token.length).to eq(64)
      end
    end
  end

  describe '.encrypt_token' do
    let(:token) { 'test_token_123' }

    it 'returns a SHA256 hash' do
      result = described_class.encrypt_token(token)
      expect(result).to be_a(String)
      expect(result.length).to eq(64)
    end

    it 'produces consistent results for the same input' do
      result1 = described_class.encrypt_token(token)
      result2 = described_class.encrypt_token(token)
      expect(result1).to eq(result2)
    end

    it 'produces different results for different inputs' do
      result1 = described_class.encrypt_token('token1')
      result2 = described_class.encrypt_token('token2')
      expect(result1).not_to eq(result2)
    end
  end

  describe '#token_expired?' do
    context 'when token has not expired' do
      subject(:device) { create(:device) }

      it { is_expected.not_to be_token_expired }
    end

    context 'when token has expired' do
      subject(:device) { create(:device, :expired) }

      it { is_expected.to be_token_expired }
    end

    context 'when expiry_time is nil' do
      subject(:device) { build(:device) }

      before { device.expiry_time = nil }

      it { is_expected.to be_token_expired }
    end
  end

  describe '#refresh_token!' do
    subject(:device) { create(:device) }

    let(:original_token) { device.plain_token }
    let(:original_encrypted_key) { device.encrypted_key }
    let(:original_expiry) { device.expiry_time }

    before do
      # Store original values before refresh
      original_token
      original_encrypted_key
      original_expiry
    end

    it 'generates a new token' do
      new_token = device.refresh_token!
      expect(new_token).not_to eq(original_token)
    end

    it 'updates the encrypted key' do
      device.refresh_token!
      expect(device.encrypted_key).not_to eq(original_encrypted_key)
    end

    it 'updates the expiry time' do
      device.refresh_token!
      expect(device.expiry_time).to be > original_expiry
    end

    it 'returns the new plain token' do
      new_token = device.refresh_token!
      expect(new_token).to eq(device.plain_token)
      expect(new_token.length).to eq(64)
    end
  end

  describe 'factory' do
    subject(:device) { build(:device) }

    it { is_expected.to be_valid }

    context 'with expired trait' do
      subject(:device) { create(:device, :expired) }

      it { is_expected.to be_token_expired }
    end

    context 'with with_sensors trait' do
      let(:device) { create(:device, :with_sensors, sensor_count: 3) }

      it 'creates associated sensors' do
        expect(device.sensors.count).to eq(3)
      end
    end
  end
end
