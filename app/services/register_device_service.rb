class RegisterDeviceService
  class << self
    def call(device_key:, device_params:)

      device = Device.new(device_params)
      if device.save
        device
      else
        raise DeviceServiceError, device.errors.full_messages.join(", ")
      end
    rescue StandardError => e
      raise DeviceServiceErrorInternal, e.message
    end
  end
end
