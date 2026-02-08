class UsersController < ApplicationController
  before_action :set_user, only: %i[ show update destroy ]

  def index
    @users = User.all
    render json: @users, except: [ :password_digest ]
  end

  def show
    render json: @user, except: [ :password_digest ]
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, location: @user, except: [ :password_digest ]
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: @user, except: [ :password_digest ]
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.expect(user: [ :nickname, :email, :password, :password_confirmation ])
    end
end
