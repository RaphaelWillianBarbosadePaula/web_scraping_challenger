require 'ostruct'

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :current_user, :user_signed_in?

  private

  def authenticate_user!
    unless user_signed_in?
      redirect_to login_path, alert: "Você precisa fazer login para acessar essa página."
    end
  end

  def user_signed_in?
    current_user.present?
  end

  def current_user
    return @current_user if defined?(@current_user)

    token = session[:jwt_token]
    return nil if token.blank?

    begin
      decoded_token = JWT.decode(token, nil, false).first

      user_id = decoded_token['user_id'] || decoded_token['sub'] || decoded_token['id']

      @current_user = OpenStruct.new(id: user_id, email: decoded_token['email'], nickname: decoded_token['nickname'])
    rescue JWT::DecodeError
      session[:jwt_token] = nil
      @current_user = nil
      nil
    end
  end
end
