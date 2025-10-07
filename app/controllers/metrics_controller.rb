class MetricsController < ApplicationController
  before_action :authenticate_device!

  def create
    begin
      metrics_data = params[:_json]
      
      unless metrics_data.is_a?(Array)
        render json: { error: "Metrics must be an array" }, status: :bad_request
        return
      end

      count = CreateMetricsService.call(device: current_device, metrics: metrics_data)
      render json: { message: "#{count} metrics created successfully" }, status: :created
    rescue MetricsServiceError => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue MetricsServiceErrorInternal => e
      render json: { error: "Internal server error" }, status: :internal_server_error
    end
  end
end
