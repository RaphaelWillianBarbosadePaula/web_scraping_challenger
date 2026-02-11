require 'rails_helper'
require 'webmock/rspec'

RSpec.describe NotificationClient do
  let(:base_url) { ENV.fetch('NOTIFICATION_SERVICE_URL', 'http://notification-service:3002') }
  let(:url) { "#{base_url}/notifications" }

  let(:task_id) { 1 }
  let(:user_id) { 10 }
  let(:event_type) { 'task_created' }
  let(:extra_data) { { url: 'http://teste.com' } }

  describe '.notify' do
    context 'when send is successful' do
      before do
        stub_request(:post, url)
          .with(
            body: {
              notification: {
                task_id: task_id,
                user_id: user_id,
                event_type: event_type,
                data: extra_data
              }
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(status: 201, body: { message: 'ok' }.to_json)
      end

      it 'sends a notification to the service' do
        NotificationClient.notify(task_id, user_id, event_type, extra_data)

        expect(WebMock).to have_requested(:post, url).once
      end
    end

    context 'when send fails' do
      before do
        stub_request(:post, url).to_raise(Faraday::ConnectionFailed.new('Connection refused'))
      end

      it 'returns an error message' do
        result = NotificationClient.notify(task_id, user_id, event_type, extra_data)

        expect(result).to respond_to(:success?)

        expect(result.success?).to be false

        expect(result.body[:error]).to eq('Serviço de Notificação indisponível')
      end
    end
  end
end