class ApplicationController < ActionController::API
  attr_reader :current_device

  def authenticate_device!
    token = request.headers["X-API-KEY"]
    
    unless token
      render json: { error: "Authentication required" }, status: :unauthorized
      return
    end

    hashed_token = Device.encrypt_token(token)
    @current_device = Device.find_by(encrypted_key: hashed_token)

    unless @current_device
      render json: { error: "Invalid authentication token" }, status: :unauthorized
      return
    end

    if @current_device.token_expired?
      render json: { error: "Token expired" }, status: :unauthorized
      return
    end
  end

  def find_device_by_token
    token = request.headers["X-API-KEY"]
    return unless token

    hashed_token = Device.encrypt_token(token)
    @current_device = Device.find_by(encrypted_key: hashed_token)
  end
end
