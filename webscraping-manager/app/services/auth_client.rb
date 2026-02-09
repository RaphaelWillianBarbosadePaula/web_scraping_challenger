require 'faraday'
require 'ostruct'

class AuthClient
  BASE_URL = ENV.fetch('AUTH_SERVICE_URL', 'http://localhost:3001')

  def self.register(nickname, email, password, password_confirmation)
    response = connection.post('/users') do |req|
      req.body = {
        user: {
          nickname: nickname,
          email: email,
          password: password,
          password_confirmation: password_confirmation
        }
      }
    end

    format_response(response)
  rescue Faraday::ConnectionFailed
    OpenStruct.new(success?: false, body: { error: 'Serviço de Autenticação indisponível' })
  end

  def self.login(email, password)
    response = connection.post('/login') do |req|
      req.body = { email: email, password: password }
    end

    format_response(response)
  rescue Faraday::ConnectionFailed
    OpenStruct.new(success?: false, body: { error: 'Serviço de Autenticação indisponível' })
  end

  private

  def self.connection
    @connection ||= Faraday.new(url: BASE_URL) do |conn|
      conn.request :json

      conn.response :json, parser_options: { symbolize_names: true }

      conn.adapter :net_http
    end
  end

  def self.format_response(response)
    errors_data = response.body[:errors] rescue nil

    formatted_errors = if errors_data.is_a?(Hash)
                         errors_data.map { |field, msgs| "#{I18n.t("activerecord.attributes.user.#{field}", default: field.to_s.humanize)} #{msgs.join(', ')}" }
                       elsif errors_data.is_a?(Array)
                         errors_data
                       else
                         []
                       end

    OpenStruct.new(
      success?: response.success?,
      body: response.body,
      status: response.status,
      errors: formatted_errors
    )
  end
end