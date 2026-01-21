class DevicesController < ApplicationController
  before_action :find_device_by_token, only: [:create]

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

  private

  def device_params
    params.permit(:id, :description)
  end
end
