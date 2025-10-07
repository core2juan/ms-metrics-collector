class MetricsController < ApplicationController

  def create
    begin
      CreateMetricsService.call(sensor_params, metric_params)
      render json: { message: "Metric created successfully" }, status: :created
    rescue MetricsServiceError => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue MetricsServiceErrorInternal => e
      render json: { error: "Internal server error" }, status: :internal_server_error
    end
  end


  private

  def sensor_params
    params.permit(:id, :description)
  end

  def metric_params
    params.permit(:description, :value, :timestamp)
  end
end
