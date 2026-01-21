# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Devices' do
  describe 'POST /devices/status' do
    let(:device) { create(:device) }
    let(:auth_token) { device.plain_token }
    let(:headers) { { 'X-API-KEY' => auth_token, 'Content-Type' => 'application/json' } }
    let(:valid_payload) do
      {
        timestamp: Time.current.to_f,
        metrics: {
          cpu_usage: 45.2,
          memory_usage: 72.1,
          temperature: 58.5
        }
      }
    end

    context 'when not authenticated' do
      let(:headers) { { 'Content-Type' => 'application/json' } }

      it 'returns unauthorized status' do
        post '/devices/status', params: valid_payload.to_json, headers: headers
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns authentication required error' do
        post '/devices/status', params: valid_payload.to_json, headers: headers
        expect(json_response['error']).to eq('Authentication required')
      end
    end

    context 'with invalid token' do
      let(:headers) { { 'X-API-KEY' => 'invalid_token_123', 'Content-Type' => 'application/json' } }

      it 'returns unauthorized status' do
        post '/devices/status', params: valid_payload.to_json, headers: headers
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns invalid token error' do
        post '/devices/status', params: valid_payload.to_json, headers: headers
        expect(json_response['error']).to eq('Invalid authentication token')
      end
    end

    context 'with expired token' do
      let(:device) { create(:device, :expired) }

      it 'returns unauthorized status' do
        post '/devices/status', params: valid_payload.to_json, headers: headers
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns token expired error' do
        post '/devices/status', params: valid_payload.to_json, headers: headers
        expect(json_response['error']).to eq('Token expired')
      end
    end

    context 'when authenticated' do
      context 'with valid payload' do
        it 'returns created status' do
          post '/devices/status', params: valid_payload.to_json, headers: headers
          expect(response).to have_http_status(:created)
        end

        it 'creates a device status metric' do
          expect {
            post '/devices/status', params: valid_payload.to_json, headers: headers
          }.to change(DeviceStatusMetric, :count).by(1)
        end

        it 'stores the metrics correctly' do
          post '/devices/status', params: valid_payload.to_json, headers: headers
          
          status_metric = DeviceStatusMetric.last
          expect(status_metric.metrics['cpu_usage']).to eq(45.2)
          expect(status_metric.metrics['memory_usage']).to eq(72.1)
          expect(status_metric.metrics['temperature']).to eq(58.5)
        end

        it 'stores the timestamp from the device' do
          timestamp = 1.hour.ago.to_f
          payload = valid_payload.merge(timestamp: timestamp)
          
          post '/devices/status', params: payload.to_json, headers: headers
          
          expect(DeviceStatusMetric.last.timestamp).to eq(timestamp)
        end

        it 'returns success message' do
          post '/devices/status', params: valid_payload.to_json, headers: headers
          expect(json_response['message']).to eq('Status recorded successfully')
        end

        it 'associates the metric with the authenticated device' do
          post '/devices/status', params: valid_payload.to_json, headers: headers
          expect(DeviceStatusMetric.last.device).to eq(device)
        end
      end

      context 'with extended metrics' do
        let(:extended_payload) do
          {
            timestamp: Time.current.to_f,
            metrics: {
              cpu_usage: 45.2,
              memory_usage: 72.1,
              temperature: 58.5,
              disk_usage: 34.0,
              network_rx_bytes: 123456,
              network_tx_bytes: 654321,
              custom_field: 'custom_value'
            }
          }
        end

        it 'stores all metrics including custom fields' do
          post '/devices/status', params: extended_payload.to_json, headers: headers
          
          status_metric = DeviceStatusMetric.last
          expect(status_metric.metrics['disk_usage']).to eq(34.0)
          expect(status_metric.metrics['network_rx_bytes']).to eq(123456)
          expect(status_metric.metrics['custom_field']).to eq('custom_value')
        end
      end

      context 'with historical/buffered metrics' do
        it 'accepts metrics with past timestamps' do
          past_timestamp = 2.days.ago.to_f
          payload = valid_payload.merge(timestamp: past_timestamp)
          
          post '/devices/status', params: payload.to_json, headers: headers
          
          expect(response).to have_http_status(:created)
          expect(DeviceStatusMetric.last.timestamp).to eq(past_timestamp)
        end
      end

      context 'with missing timestamp' do
        let(:payload_without_timestamp) do
          { metrics: { cpu_usage: 45.2 } }
        end

        it 'returns unprocessable content status' do
          post '/devices/status', params: payload_without_timestamp.to_json, headers: headers
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'returns validation error' do
          post '/devices/status', params: payload_without_timestamp.to_json, headers: headers
          expect(json_response['error']).to include("Timestamp can't be blank")
        end
      end

      context 'with missing metrics' do
        let(:payload_without_metrics) do
          { timestamp: Time.current.to_f }
        end

        it 'returns unprocessable content status' do
          post '/devices/status', params: payload_without_metrics.to_json, headers: headers
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'returns validation error' do
          post '/devices/status', params: payload_without_metrics.to_json, headers: headers
          expect(json_response['error']).to include("Metrics can't be blank")
        end
      end

      context 'with empty metrics hash' do
        let(:payload_with_empty_metrics) do
          { timestamp: Time.current.to_f, metrics: {} }
        end

        it 'returns unprocessable content status' do
          post '/devices/status', params: payload_with_empty_metrics.to_json, headers: headers
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
