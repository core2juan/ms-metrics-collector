class ApplicationController < ActionController::API
  def device_key
    request.headers["X-API-KEY"]
  end
end
