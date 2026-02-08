class UserRegistrationsController < ApplicationController
  def new
  end

  def create
    response = AuthClient.register(
      params[:nickname],
      params[:email],
      params[:password],
      params[:password_confirmation]
    )

    if response.success?
      flash.now[:notice] = 'Conta criada! Faça login para continuar.'
      render :new, status: :created
    else
      @errors_list = response.errors

      flash.now[:alert] = "#{@errors_list.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  end
end
