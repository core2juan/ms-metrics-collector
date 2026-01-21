# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Metrics' do
  describe 'POST /metrics' do
    let(:device) { create(:device) }
    let(:auth_token) { device.plain_token }
    let(:headers) { { 'X-API-KEY' => auth_token, 'Content-Type' => 'application/json' } }
    let(:valid_metrics) do
      [
        {
          id: 'sensor_1',
          value: 42.5,
          timestamp: Time.current.to_f,
          description: 'FloatSensor: Temperature reading'
        },
        {
          id: 'sensor_2',
          value: 55.0,
          timestamp: Time.current.to_f,
          description: 'FloatSensor: Humidity reading'
        }
      ]
    end

    context 'when not authenticated' do
      let(:headers) { { 'Content-Type' => 'application/json' } }

      it 'returns unauthorized status' do
        post '/metrics', params: valid_metrics.to_json, headers: headers
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns authentication required error' do
        post '/metrics', params: valid_metrics.to_json, headers: headers
        expect(json_response['error']).to eq('Authentication required')
      end
    end

    context 'with invalid token' do
      let(:headers) { { 'X-API-KEY' => 'invalid_token_123', 'Content-Type' => 'application/json' } }

      it 'returns unauthorized status' do
        post '/metrics', params: valid_metrics.to_json, headers: headers
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns invalid token error' do
        post '/metrics', params: valid_metrics.to_json, headers: headers
        expect(json_response['error']).to eq('Invalid authentication token')
      end
    end

    context 'with expired token' do
      let(:device) { create(:device, :expired) }

      it 'returns unauthorized status' do
        post '/metrics', params: valid_metrics.to_json, headers: headers
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns token expired error' do
        post '/metrics', params: valid_metrics.to_json, headers: headers
        expect(json_response['error']).to eq('Token expired')
      end
    end

    context 'when authenticated' do
      context 'with valid metrics array' do
        it 'returns created status' do
          post '/metrics', params: valid_metrics.to_json, headers: headers
          expect(response).to have_http_status(:created)
        end

        it 'creates the metrics' do
          expect {
            post '/metrics', params: valid_metrics.to_json, headers: headers
          }.to change(Metric, :count).by(2)
        end

        it 'creates sensors for new sensor external_ids' do
          expect {
            post '/metrics', params: valid_metrics.to_json, headers: headers
          }.to change(Sensor, :count).by(2)
        end

        it 'returns success message with count' do
          post '/metrics', params: valid_metrics.to_json, headers: headers
          expect(json_response['message']).to eq('2 metrics created successfully')
        end

        context 'with existing sensor' do
          let!(:existing_sensor) { create(:sensor, external_id: 'sensor_1', type: 'Sensors::FloatSensor', device: device) }

          it 'does not create duplicate sensor' do
            expect {
              post '/metrics', params: valid_metrics.to_json, headers: headers
            }.to change(Sensor, :count).by(1)
          end
        end
      end

      context 'with non-array payload' do
        let(:invalid_payload) { { id: 'sensor_1', value: 42.5 } }

        it 'returns bad request status' do
          post '/metrics', params: invalid_payload.to_json, headers: headers
          expect(response).to have_http_status(:bad_request)
        end

        it 'returns appropriate error message' do
          post '/metrics', params: invalid_payload.to_json, headers: headers
          expect(json_response['error']).to eq('Metrics must be an array')
        end
      end

      context 'with missing required fields' do
        let(:incomplete_metrics) do
          [
            {
              id: 'sensor_1',
              description: 'FloatSensor: Temperature reading'
              # missing value and timestamp
            }
          ]
        end

        it 'returns unprocessable entity status' do
          post '/metrics', params: incomplete_metrics.to_json, headers: headers
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'returns error details' do
          post '/metrics', params: incomplete_metrics.to_json, headers: headers
          expect(json_response['error']).to include('Missing required fields')
        end
      end

      context 'with unknown sensor type' do
        let(:invalid_type_metrics) do
          [
            {
              id: 'sensor_1',
              value: 42.5,
              timestamp: Time.current.to_f,
              description: 'UnknownSensor: Some reading'
            }
          ]
        end

        it 'returns unprocessable entity status' do
          post '/metrics', params: invalid_type_metrics.to_json, headers: headers
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'returns unknown sensor type error' do
          post '/metrics', params: invalid_type_metrics.to_json, headers: headers
          expect(json_response['error']).to include('Unknown sensor type')
        end
      end

      context 'with invalid description format' do
        let(:invalid_description_metrics) do
          [
            {
              id: 'sensor_1',
              value: 42.5,
              timestamp: Time.current.to_f,
              description: 'Invalid format without colon'
            }
          ]
        end

        it 'returns unprocessable entity status' do
          post '/metrics', params: invalid_description_metrics.to_json, headers: headers
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'returns invalid sensor type error' do
          post '/metrics', params: invalid_description_metrics.to_json, headers: headers
          expect(json_response['error']).to include('Missing or invalid sensor type')
        end
      end

      context 'with energy consumption sensor type' do
        let(:energy_metrics) do
          [
            {
              id: 'energy_sensor_1',
              value: 250.5,
              timestamp: Time.current.to_f,
              description: 'EnergyConsumptionSensor: Power consumption'
            }
          ]
        end

        it 'creates energy consumption sensor' do
          post '/metrics', params: energy_metrics.to_json, headers: headers
          expect(Sensor.last.type).to eq('Sensors::EnergyConsumptionSensor')
        end
      end

      context 'with empty array' do
        it 'returns created status' do
          post '/metrics', params: [].to_json, headers: headers
          expect(response).to have_http_status(:created)
        end

        it 'returns zero count message' do
          post '/metrics', params: [].to_json, headers: headers
          expect(json_response['message']).to eq('0 metrics created successfully')
        end
      end
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
