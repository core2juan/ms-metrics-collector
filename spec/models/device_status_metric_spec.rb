# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeviceStatusMetric do
  describe 'associations' do
    it { is_expected.to belong_to(:device) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:metrics) }
    it { is_expected.to validate_presence_of(:timestamp) }
  end

  describe 'factory' do
    subject(:device_status_metric) { build(:device_status_metric) }

    it { is_expected.to be_valid }

    it 'has metrics hash with expected keys' do
      expect(device_status_metric.metrics).to include('cpu_usage', 'memory_usage', 'temperature')
    end

    context 'with with_full_metrics trait' do
      subject(:device_status_metric) { build(:device_status_metric, :with_full_metrics) }

      it { is_expected.to be_valid }

      it 'includes additional metrics' do
        expect(device_status_metric.metrics).to include(
          'cpu_usage', 'memory_usage', 'temperature',
          'disk_usage', 'network_rx_bytes', 'network_tx_bytes'
        )
      end
    end

    context 'with historical trait' do
      subject(:device_status_metric) { build(:device_status_metric, :historical) }

      it { is_expected.to be_valid }

      it 'has a past timestamp' do
        expect(device_status_metric.timestamp).to be < Time.current.to_f
      end
    end
  end

  describe 'metrics storage' do
    let(:device) { create(:device) }
    let(:metrics_data) do
      {
        cpu_usage: 45.2,
        memory_usage: 72.1,
        temperature: 58.5,
        custom_metric: 'test_value'
      }
    end

    it 'stores arbitrary metrics in JSONB field' do
      status_metric = described_class.create!(
        device: device,
        timestamp: Time.current.to_f,
        metrics: metrics_data
      )

      status_metric.reload
      expect(status_metric.metrics['cpu_usage']).to eq(45.2)
      expect(status_metric.metrics['custom_metric']).to eq('test_value')
    end
  end
end
