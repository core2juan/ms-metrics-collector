class CreateMetricsService
  AVAILABLE_SENSOR_TYPES = Sensors.constants.map(&:to_s).freeze

  class << self
    def call(device:, metrics:)
      sensor_cache = preload_sensors(device, metrics)
      metrics_to_insert = []
      invalid_metrics = []

      metrics.each do |metric_data|
        sensor_id = metric_data[:id] || metric_data["id"]
        value = metric_data[:value] || metric_data["value"]
        timestamp = metric_data[:timestamp] || metric_data["timestamp"]
        description = metric_data[:description] || metric_data["description"]
        
        if value.nil? || timestamp.nil? || description.nil?
          invalid_metrics << { sensor_id: sensor_id, error: "Missing required fields (value, timestamp, or description)" }
          next
        end
        
        sensor = get_or_create_sensor(device, metric_data, sensor_cache)
        
        metrics_to_insert << {
          sensor_id: sensor.id,
          value: value,
          timestamp: timestamp,
          description: description,
          created_at: Time.current,
          updated_at: Time.current
        }
      end

      if invalid_metrics.any?
        valid_count = metrics_to_insert.count
        error_msg = "#{valid_count} metrics valid, #{invalid_metrics.count} dropped. Errors: #{invalid_metrics.map { |e| "sensor[#{e[:sensor_id]}]: #{e[:error]}" }.join('; ')}"
        raise MetricsServiceError, error_msg
      end

      result = Metric.insert_all(metrics_to_insert) if metrics_to_insert.any?
      result&.count || 0
    rescue MetricsServiceError
      raise
    rescue Exception => e
      raise MetricsServiceErrorInternal, e.message
    end

    def preload_sensors(device, metrics)
      external_ids = []
      types = []

      metrics.each do |metric_data|
        description = metric_data[:description] || metric_data["description"]
        sensor_id = metric_data[:id] || metric_data["id"]
        
        match = description.to_s.match(/^([\w:]+):/)
        type = match && match[1]
        raise MetricsServiceError, "Missing or invalid sensor type in description" unless type
        raise MetricsServiceError, "Unknown sensor type: #{type}" unless AVAILABLE_SENSOR_TYPES.include?(type)

        external_ids << sensor_id
        types << "Sensors::#{type}"
      end

      sensors = device.sensors.where(external_id: external_ids.uniq, type: types.uniq)
      sensors.index_by { |s| "#{s.external_id}:#{s.type}" }
    end

    def get_or_create_sensor(device, metric_data, sensor_cache)
      description = metric_data[:description] || metric_data["description"]
      sensor_id = metric_data[:id] || metric_data["id"]
      
      match = description.to_s.match(/^([\w:]+):/)
      type = match && match[1]
      full_type = "Sensors::#{type}"

      cache_key = "#{sensor_id}:#{full_type}"
      
      sensor_cache[cache_key] ||= device.sensors.create!(external_id: sensor_id, type: full_type)
    end
  end

  private_class_method :preload_sensors, :get_or_create_sensor
end
