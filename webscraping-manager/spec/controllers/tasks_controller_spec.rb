require 'rails_helper'

RSpec.describe TasksController, type: :controller do
  let(:user) { OpenStruct.new(id: 1, email: 'teste@example.com') }

  let(:task) { build_stubbed(:task, id: 1, user_id: user.id) }

  let(:valid_attributes) { { title: 'Test Task', url: 'http://example.com' } }
  let(:invalid_attributes) { { title: '', url: '' } }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)

    allow(Task).to receive(:find_by!).with(id: task.id.to_s, user_id: user.id).and_return(task)
  end

  describe 'GET #index' do
    it 'returns a success response' do
      allow(Task).to receive(:where).with(user_id: user.id).and_return(Task.none)

      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response and fetches notifications' do
      allow(NotificationClient).to receive(:get_by_task).with(task.id).and_return([])
      get :show, params: { id: task.id }
      expect(response).to be_successful
      expect(assigns(:notifications)).to eq([])
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Task' do
        allow(Task).to receive(:new).and_return(task)
        allow(task).to receive(:save).and_return(true)
        allow(task).to receive(:user_id=).with(user.id)

        allow(NotificationClient).to receive(:notify).with(task.id, user.id, 'task_created', { url: task.url })

        post :create, params: { task: valid_attributes }
        expect(response).to redirect_to(tasks_path)
      end
    end

    context 'with invalid params' do
      it "returns an unprocessable_content response" do
        allow(Task).to receive(:new).and_return(task)
        allow(task).to receive(:user_id=).with(user.id)
        allow(task).to receive(:save).and_return(false)

        post :create, params: { task: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PUT #update' do
    let(:new_attributes) { { title: 'New Title' } }

    context 'with valid params' do
      it 'updates the requested task' do
        allow(task).to receive(:update).and_return(true)

        put :update, params: { id: task.id, task: new_attributes }
        expect(response).to redirect_to(tasks_path)
      end
    end

    context 'with invalid params' do
      it "returns an unprocessable_content response" do
        allow(task).to receive(:update).and_return(false)

        put :update, params: { id: task.id, task: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested task' do
      allow(task).to receive(:destroy).and_return(true)

      delete :destroy, params: { id: task.id }

      expect(task).to have_received(:destroy)
      expect(response).to redirect_to(tasks_path)
    end
  end
end