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
end
