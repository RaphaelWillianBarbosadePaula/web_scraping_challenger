require 'rails_helper'

RSpec.describe UserRegistrationsController, type: :controller do
  describe "GET #new" do
    it "return success" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      {
        nickname: 'raphael',
        email: 'teste@email.com',
        password: 'password123',
        password_confirmation: 'password123'
      }
    end

    context "when the registration is successful" do
      before do
        auth_response = OpenStruct.new(success?: true)
        allow(AuthClient).to receive(:register).and_return(auth_response)
      end

      it "render 'new' with status 201" do
        post :create, params: valid_params
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:created)
      end

      it "set a sucess message in flash" do
        post :create, params: valid_params
        expect(flash.now[:notice]).to eq('Conta criada! Faça login para continuar.')
      end
    end

    context "when the registration fails" do
      let(:error_messages) { ["Email já está em uso", "Nickname já está em uso"] }

      before do
        auth_response = OpenStruct.new(success?: false, errors: error_messages)
        allow(AuthClient).to receive(:register).and_return(auth_response)
      end

      it "render 'new' with status 422" do
        post :create, params: valid_params
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "set @errors_list with the errors" do
        post :create, params: valid_params
        expect(assigns(:errors_list)).to eq(error_messages)
      end

      it "set a error message in flash" do
        post :create, params: valid_params
        expect(flash.now[:alert]).to include("Email já está em uso")
      end
    end
  end
end