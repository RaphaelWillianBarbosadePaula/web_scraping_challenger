class NotificationsController < ApplicationController
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