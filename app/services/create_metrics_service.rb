class CreateMetricsService
  AVAILABLE_SENSOR_TYPES = Sensors.constants.map(&:to_s).freeze

  class << self
    def call(sensor_params:, metric_params:)
      sensor = initialize_sensor(sensor_params)
      metric = sensor.metrics.new(metric_params)
      if metric.save
        metric
      else
        raise MetricsServiceError, "Failed to save metric: #{metric.errors.full_messages.join(', ')}"
      end
    end

    def initialize_sensor(sensor_params)
      match = sensor_params[:description].to_s.match(/^([\w:]+):/)
      type = match && match[1]
      raise MetricsServiceError, "Missing or invalid sensor type in description" unless type
      raise MetricsServiceError, "Unknown sensor type: #{type}" unless AVAILABLE_SENSOR_TYPES.include?(type)

      begin
        @sensor ||= Sensor.where(external_id: sensor_params[:id], type: "Sensors::#{type}").first_or_create
      rescue => e
        raise MetricsServiceErrorInternal, "Failed to initialize sensor: #{e.message}"
      end
    end
  end

  private_class_method :initialize_sensor
end
