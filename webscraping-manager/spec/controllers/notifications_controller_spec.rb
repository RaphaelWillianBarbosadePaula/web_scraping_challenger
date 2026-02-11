require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  let(:user) { OpenStruct.new(id: 1, email: 'teste@example.com') }

  let(:fake_notifications) do
    [
      { 'id' => 10, 'event_type' => 'task_created', 'user_id' => user.id },
      { 'id' => 11, 'event_type' => 'task_failed', 'user_id' => user.id }
    ]
  end

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'fetches notifications for the current user and returns success' do
      expect(NotificationClient).to receive(:get_all).with(user.id).and_return(fake_notifications)

      get :index

      expect(response).to be_successful
      expect(assigns(:notifications)).to eq(fake_notifications)
      expect(response).to render_template(:index)
    end
  end
end