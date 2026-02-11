require 'faraday'
require 'json'
require 'ostruct'

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

  def self.get_all(user_id = nil)
    params = {}
    params[:user_id] = user_id if user_id.present?

    response = Faraday.get("#{BASE_URL}/notifications", params)

    if response.success?
      JSON.parse(response.body)
    else
      []
    end
  rescue Faraday::ConnectionFailed => e
    Rails.logger.error "Erro ao buscar notificações gerais: #{e.message}"
    []
  end

  def self.get_by_task(task_id)
    response = Faraday.get("#{BASE_URL}/notifications", { task_id: task_id })

    if response.success?
      JSON.parse(response.body)
    else
      []
    end
  rescue Faraday::ConnectionFailed => e
    Rails.logger.error "Erro ao buscar notificações: #{e.message}"
    OpenStruct.new(success?: false, body: { error: 'Serviço de Notificação indisponível' })
    []
  end
end