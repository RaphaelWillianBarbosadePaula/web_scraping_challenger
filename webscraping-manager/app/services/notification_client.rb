require 'faraday'

class NotificationClient
  BASE_URL = ENV.fetch('NOTIFICATION_SERVICE_URL', 'http://notification-service:3002')

  def self.notify(task_id, user_id, event_type, extra_data = {})
    Faraday.post("#{BASE_URL}/notifications") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        notification: {
          task_id: task_id,
          user_id: user_id,
          event_type: event_type,
          data: extra_data
        }
      }.to_json
    end
  rescue Faraday::ConnectionFailed => e
    Rails.logger.error "Notification Service Error: #{e.message}"

    OpenStruct.new(success?: false, body: { error: 'Serviço de Notificação indisponível' })
  end
end