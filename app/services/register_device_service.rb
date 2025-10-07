class RegisterDeviceService
  class << self
    def call(device:, device_params:)
      if device
        token = device.refresh_token!
        return { device: device, token: token }
      end

      device = Device.find_by(external_id: device_params[:id])
      
      if device
        token = device.refresh_token!
      else
        device = Device.new(external_id: device_params[:id], description: device_params[:description])
        if device.save
          token = device.plain_token
        else
          raise DeviceServiceError, device.errors.full_messages.join(", ")
        end
      end

      { device: device, token: token }
    rescue DeviceServiceError
      raise
    rescue Exception => e
      raise DeviceServiceErrorInternal, e.message
    end
  end
end
