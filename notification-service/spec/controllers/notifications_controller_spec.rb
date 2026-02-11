require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_attributes) { attributes_for(:notification) }

      it 'creates a new Notification' do
        expect {
          post :create, params: { notification: valid_attributes }
        }.to change(Notification, :count).by(1)
      end

      it 'renders a JSON response with a new notification' do
        post :create, params: { notification: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { attributes_for(:notification, task_id: nil) }

      it 'does not create a new Notification' do
        expect {
          post :create, params: { notification: invalid_attributes }
        }.not_to change(Notification, :count)
      end

      it 'renders a JSON response with errors for the new notification' do
        post :create, params: { notification: invalid_attributes  }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe 'GET #index' do
    before { Notification.destroy_all }

    let!(:notification_1) { create(:notification, task_id: 100, user_id: 1, created_at: 1.hour.ago) }
    let!(:notification_2) { create(:notification, task_id: 100, user_id: 2, created_at: 2.hours.ago) }
    let!(:notification_3) { create(:notification, task_id: 200, user_id: 1, created_at: 3.hours.ago) }

    context 'without filters' do
      before { get :index }

      it 'returns a success response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all notifications ordered by created_at desc' do
        json_response = JSON.parse(response.body)

        expect(json_response.size).to eq(3)
        expect(json_response.first['id']).to eq(notification_1.id)
        expect(json_response.last['id']).to eq(notification_3.id)
      end
    end

    context 'filtering by task_id' do
      it 'returns only notifications for the specific task' do
        get :index, params: { task_id: 100 }
        json_response = JSON.parse(response.body)

        ids = json_response.map { |n| n['id'] }

        expect(ids).to include(notification_1.id, notification_2.id)
        expect(ids).not_to include(notification_3.id)
      end
    end

    context 'filtering by user_id' do
      it 'returns only notifications for the specific user' do
        get :index, params: { user_id: 1 }
        json_response = JSON.parse(response.body)

        ids = json_response.map { |n| n['id'] }

        expect(ids).to include(notification_1.id, notification_3.id)
        expect(ids).not_to include(notification_2.id)
      end
    end

    context 'filtering by both parameters' do
      it 'returns precise match' do
        get :index, params: { task_id: 100, user_id: 2 }
        json_response = JSON.parse(response.body)

        expect(json_response.size).to eq(1)
        expect(json_response.first['id']).to eq(notification_2.id)
      end
    end
  end
end
