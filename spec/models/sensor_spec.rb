# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sensor do
  describe 'associations' do
    it { is_expected.to belong_to(:device) }
    it { is_expected.to have_many(:metrics).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:sensor) }

    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_uniqueness_of(:external_id).scoped_to(:type) }
  end

  describe 'factory' do
    subject(:sensor) { build(:sensor) }

    it { is_expected.to be_valid }

    context 'with energy_consumption trait' do
      subject(:sensor) { build(:sensor, :energy_consumption) }

      it { is_expected.to be_valid }

      it 'has EnergyConsumptionSensor type' do
        expect(sensor.type).to eq('Sensors::EnergyConsumptionSensor')
      end
    end

    context 'with_metrics trait' do
      let(:sensor) { create(:sensor, :with_metrics, metric_count: 5) }

      it 'creates associated metrics' do
        expect(sensor.metrics.count).to eq(5)
      end
    end
  end

  describe 'STI subclasses' do
    describe Sensors::FloatSensor do
      subject(:sensor) { build(:float_sensor) }

      it { is_expected.to be_valid }
      it { is_expected.to be_a(Sensor) }
    end

    describe Sensors::EnergyConsumptionSensor do
      subject(:sensor) { build(:energy_consumption_sensor) }

      it { is_expected.to be_valid }
      it { is_expected.to be_a(Sensor) }
    end
  end
end
