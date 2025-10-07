class DevicesController < ApplicationController

  def create
    begin
      device = RegisterDeviceService.call(device_key, device_params)
      render json: { message: "Device created successfully", device: device }, status: :created
    rescue ::DeviceServiceError => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue ::DeviceServiceErrorInternal => e
      render json: { error: "Internal server error" }, status: :internal_server_error
    end
  end

  private

  def device_params
    params.permit(:id, :description)
  end
end
