require 'rails_helper'
require 'webmock/rspec'

RSpec.describe NotificationClient do
  let(:base_url) { ENV.fetch('NOTIFICATION_SERVICE_URL', 'http://notification-service:3002') }
  let(:url) { "#{base_url}/notifications" }

  let(:task_id) { 1 }
  let(:user_id) { 10 }
  let(:event_type) { 'task_created' }
  let(:extra_data) { { url: 'http://teste.com' } }

  let(:json_response) do
    [
      { 'id' => 1, 'event_type' => 'task_created', 'task_id' => task_id },
      { 'id' => 2, 'event_type' => 'task_completed', 'task_id' => task_id }
    ]
  end

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

  describe '.get_all' do
    context 'when fetching without filters' do
      before do
        stub_request(:get, url)
          .to_return(status: 200, body: json_response.to_json)
      end

      it 'returns a list of notifications' do
        result = NotificationClient.get_all
        expect(result).to be_an(Array)
        expect(result.size).to eq(2)
        expect(result.first['event_type']).to eq('task_created')
      end
    end

    context 'when fetching with user_id' do
      before do
        stub_request(:get, url)
          .with(query: { user_id: user_id })
          .to_return(status: 200, body: json_response.to_json)
      end

      it 'sends user_id parameter' do
        result = NotificationClient.get_all(user_id)
        expect(result).to be_an(Array)
        expect(WebMock).to have_requested(:get, url).with(query: { user_id: user_id })
      end
    end

    context 'when connection fails' do
      before do
        stub_request(:get, url).to_raise(Faraday::ConnectionFailed.new('Connection refused'))
      end

      it 'returns an empty array' do
        result = NotificationClient.get_all
        expect(result).to eq([])
      end
    end
  end

  describe '.get_by_task' do
    context 'when request is successful' do
      before do
        stub_request(:get, url)
          .with(query: { task_id: task_id })
          .to_return(status: 200, body: json_response.to_json)
      end

      it 'returns notifications for the specific task' do
        result = NotificationClient.get_by_task(task_id)

        expect(result).to be_an(Array)
        expect(result.first['task_id']).to eq(task_id)
        expect(WebMock).to have_requested(:get, url).with(query: { task_id: task_id })
      end
    end

    context 'when connection fails' do
      before do
        stub_request(:get, url)
          .with(query: { task_id: task_id })
          .to_raise(Faraday::ConnectionFailed.new('Connection refused'))
      end

      it 'returns an empty array' do
        result = NotificationClient.get_by_task(task_id)
        expect(result).to eq([])
      end
    end

    context 'when service returns error (e.g. 500)' do
      before do
        stub_request(:get, url)
          .with(query: { task_id: task_id })
          .to_return(status: 500, body: "")
      end

      it 'returns an empty array' do
        result = NotificationClient.get_by_task(task_id)
        expect(result).to eq([])
      end
    end
  end
end