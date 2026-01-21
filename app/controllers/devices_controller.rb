class DevicesController < ApplicationController
  before_action :find_device_by_token, only: [:create]
  before_action :authenticate_device!, only: [:status]

  def create
    begin
      result = RegisterDeviceService.call(device: current_device, device_params: device_params)
      render json: { 
        message: "Device registered successfully", 
        device: { id: result[:device].id, external_id: result[:device].external_id },
        token: result[:token] 
      }, status: :created
    rescue ::DeviceServiceError => e
      render json: { error: e.message }, status: :unprocessable_content
    rescue ::DeviceServiceErrorInternal => e
      render json: { error: "Internal server error" }, status: :internal_server_error
    end
  end

  def status
    status_metric = current_device.device_status_metrics.new(status_params)

    if status_metric.save
      render json: { message: "Status recorded successfully" }, status: :created
    else
      render json: { error: status_metric.errors.full_messages.join(", ") }, status: :unprocessable_content
    end
  end

  private

  def device_params
    params.permit(:id, :description)
  end

  def status_params
    params.permit(:timestamp, metrics: {})
  end
end
