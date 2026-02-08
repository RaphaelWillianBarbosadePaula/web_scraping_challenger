require 'rails_helper'
require 'jwt'

RSpec.describe JwtHandler, type: :service do
  let(:user) { create(:user) }
  let(:payload) { { user_id: user.id } }

  describe '.encode' do
    it 'encodes a payload into a JWT token' do
      token = described_class.encode(payload)
      decoded_token = JWT.decode(token, described_class::SECRET_KEY, true, algorithm: 'HS256')
      expect(decoded_token[0]['user_id']).to eq(user.id)
    end
  end

  describe '.decode' do
    it 'decodes a JWT token into a hash with indifferent access' do
      token = described_class.encode(payload)
      decoded_payload = described_class.decode(token)
      expect(decoded_payload[:user_id]).to eq(user.id)
    end

    it 'raises an error if the token is expired' do
      expired_token = described_class.encode(payload, 1.second.ago)
      sleep(2)
      expect { described_class.decode(expired_token) }.to raise_error(JWT::ExpiredSignature)
    end
  end
end
