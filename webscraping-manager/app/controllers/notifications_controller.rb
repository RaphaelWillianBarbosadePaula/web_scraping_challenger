class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = NotificationClient.get_all(current_user.id)
  end
end