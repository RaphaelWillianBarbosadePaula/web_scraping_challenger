class ApplicationController < ActionController::API
  rescue_from JWT::ExpiredSignature, with: :handle_expired_token
  rescue_from JWT::DecodeError, with: :handle_invalid_token

  private

  def handle_expired_token
    render json: { error: "Token expirado" }, status: :unauthorized
  end

  def handle_invalid_token(exception)
    render json: { error: "Token inválido", details: exception.message }, status: :unauthorized
  end
end
