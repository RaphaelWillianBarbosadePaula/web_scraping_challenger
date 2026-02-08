class AuthenticationController < ApplicationController
  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = JwtHandler.encode(user_id: user.id)

      render json: { token: token, exp: 24.hours.from_now }, status: :ok
    else
      render json: { error: "Credenciais inválidas" }, status: :unauthorized
    end
  end
end
