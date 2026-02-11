class NotificationsController < ApplicationController
  def index
    scope = Notification.all

    scope = scope.where(task_id: params[:task_id]) if params[:task_id].present?
    scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?

    notifications = scope.order(created_at: :desc).limit(100)

    render json: notifications
  end

  def create
    notification = Notification.new(notification_params)
    if notification.save
      render json: { message: 'Notificação registrada' }, status: :created
    else
      render json: { errors: notification.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def notification_params
    params.require(:notification).permit(:task_id, :user_id, :event_type, data: {})
  end
end