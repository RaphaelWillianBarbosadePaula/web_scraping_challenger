require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:valid_attributes) {
    attributes_for(:user)
  }

  let(:invalid_attributes) {
    { nickname: nil, email: nil, password: nil, password_confirmation: nil }
  }

  describe "GET #index" do
    it "returns a success response" do
      User.create! valid_attributes
      get :index, params: {}
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      user = User.create! valid_attributes
      get :show, params: {id: user.to_param}
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new User" do
        expect {
          post :create, params: {user: valid_attributes}
        }.to change(User, :count).by(1)
      end

      it "renders a JSON response with the new user" do
        post :create, params: {user: valid_attributes}
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(response.location).to eq(user_url(User.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new user" do
        post :create, params: {user: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        { nickname: "NovoNome" }
      }

      it "updates the requested user" do
        user = User.create! valid_attributes
        put :update, params: {id: user.to_param, user: new_attributes}
        user.reload
        expect(user.nickname).to eq("NovoNome")
      end

      it "renders a JSON response with the user" do
        user = User.create! valid_attributes
        put :update, params: {id: user.to_param, user: new_attributes}
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the user" do
        user = User.create! valid_attributes
        put :update, params: {id: user.to_param, user: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested user" do
      user = User.create! valid_attributes
      expect {
        delete :destroy, params: {id: user.to_param}
      }.to change(User, :count).by(-1)
    end
  end
end
