require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe "GET #new" do
    it "render login screen" do
      get :new
      expect(response).to be_successful
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    let(:email) { "user@teste.com" }
    let(:password) { "password123" }

    context "when login is successful" do
      let(:token) { "um-token-jwt-valido" }

      before do
        auth_result = OpenStruct.new(success?: true, body: { token: token })
        allow(AuthClient).to receive(:login).with(email, password).and_return(auth_result)
      end

      it "stores the token in the session" do
        post :create, params: { email: email, password: password }
        expect(session[:jwt_token]).to eq(token)
      end

      it "redirect to root path with success message" do
        post :create, params: { email: email, password: password }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq('Login realizado!')
      end
    end

    context "when login fails" do
      before do
        auth_result = OpenStruct.new(success?: false, body: { error: 'Credenciais inválidas' })
        allow(AuthClient).to receive(:login).with(email, password).and_return(auth_result)
      end

      it "do not store the token in the session" do
        post :create, params: { email: email, password: password }
        expect(session[:jwt_token]).to be_nil
      end

      it "render login screen with error message" do
        post :create, params: { email: email, password: password }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_content)
        expect(flash.now[:alert]).to eq('Credenciais inválidas')
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      # Simula um usuário já logado colocando um token na session
      session[:jwt_token] = "token-qualquer"
    end

    it "clear the session" do
      delete :destroy
      expect(session[:jwt_token]).to be_nil
    end

    it "redirect to login path with success message of logout" do
      delete :destroy
      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to eq('Desconectado.')
    end
  end
end