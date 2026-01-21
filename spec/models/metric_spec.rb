# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metric do
  describe 'associations' do
    it { is_expected.to belong_to(:sensor) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:timestamp) }
    it { is_expected.to validate_presence_of(:value) }
  end

  describe 'factory' do
    subject(:metric) { build(:metric) }

    it { is_expected.to be_valid }

    context 'with energy_reading trait' do
      subject(:metric) { build(:metric, :energy_reading) }

      it { is_expected.to be_valid }

      it 'has energy consumption description' do
        expect(metric.description).to include('EnergyConsumptionSensor')
      end
    end
  end
end
