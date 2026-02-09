require 'rails_helper'
require 'webmock/rspec'

RSpec.describe AuthClient do
  let(:base_url) { 'http://auth-service:3001' }

  describe '.register' do
    let(:url) { "#{base_url}/users" }
    let(:user_params) do
      { nickname: 'testuser', email: 'test@example.com', password: 'password', password_confirmation: 'password' }
    end

    context 'when is successful' do
      before do
        stub_request(:post, url)
          .with(body: { user: user_params }.to_json)
          .to_return(status: 201, body: { status: 'success' }.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'return success as true' do
        response = AuthClient.register(*user_params.values)
        expect(response.success?).to be true
      end
    end

    context 'when is not successful' do
      before do
        stub_request(:post, url)
          .to_return(
            status: 422,
            body: { errors: { email: ['já está em uso'] } }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'return success as false and errors' do
        response = AuthClient.register(*user_params.values)
        expect(response.success?).to be false
        expect(response.errors).to include("E-mail já está em uso")
      end
    end
  end

  describe '.login' do
    let(:url) { "#{base_url}/login" }
    let(:email) { 'test@example.com' }
    let(:password) { 'password123' }

    context 'with valid credentials' do
      before do
        stub_request(:post, url)
          .with(body: { email: email, password: password }.to_json)
          .to_return(
            status: 200,
            body: { token: 'fake-jwt-token' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'authenticate user and return token' do
        response = AuthClient.login(email, password)
        expect(response.success?).to be true
        expect(response.body[:token]).to eq('fake-jwt-token')
      end
    end

    context 'when service is unavailable' do
      before do
        stub_request(:post, url).to_raise(Faraday::ConnectionFailed.new('Conn failed'))
      end

      it 'catch exception and return error message' do
        response = AuthClient.login(email, password)
        expect(response.success?).to be false
        expect(response.body[:error]).to eq('Serviço de Autenticação indisponível')
      end
    end
  end
end