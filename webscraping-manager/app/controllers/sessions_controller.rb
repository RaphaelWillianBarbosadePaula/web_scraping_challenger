class SessionsController < ApplicationController
  def new
  end

  def create
    result = AuthClient.login(params[:email], params[:password])

    if result.success?
      session[:jwt_token] = result.body[:token]
      redirect_to root_path, notice: 'Login realizado!'
    else
      error_msg = result.body[:error] || "Erro desconhecido"
      flash.now[:alert] = error_msg
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:jwt_token] = nil
    redirect_to login_path, notice: 'Desconectado.'
  end
end