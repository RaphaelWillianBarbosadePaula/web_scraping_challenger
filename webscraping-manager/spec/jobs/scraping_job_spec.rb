require 'rails_helper'

RSpec.describe ScrapingJob, type: :job do
  describe '#perform' do
    let(:user_id) { 90 }
    let(:task) { Task.create(title: 'Teste', url: 'http://exemplo.com', user_id: user_id, status: 'pending') }

    let(:scraper_double) { instance_double(WebMotorsScraper) }

    let(:success_result) do
      { brand: 'Honda', model: 'Civic', price: 'R$ 100.000', note: 'Via Teste' }
    end

    before do
      allow(NotificationClient).to receive(:notify)

      allow(WebMotorsScraper).to receive(:new).with(task.url).and_return(scraper_double)
    end

    context 'when the scraping is successful' do
      before do
        allow(scraper_double).to receive(:scrape).and_return(success_result)

        # Executa o Job
        described_class.perform_now(task.id)

        task.reload
      end

      it 'update the task status to concluded' do
        expect(task.status).to eq('concluded')
      end

      it 'saves the collected data in result_data' do
        expect(task.result_data).to eq(success_result.as_json)
      end

      it 'sends a notification to the user' do
        expect(NotificationClient).to have_received(:notify).with(
          task.id,
          user_id,
          'task_completed',
          hash_including(message: include('Coleta finalizada'))
        )
      end
    end

    context 'when the scraping fails because is nil' do
      before do
        allow(scraper_double).to receive(:scrape).and_return({})

        described_class.perform_now(task.id)
        task.reload
      end

      it 'update the task status to failed' do
        expect(task.status).to eq('failed')
      end

      it 'saves the error message in result_data' do
        expect(task.result_data['error']).to include('Não foi possível extrair os dados')
      end

      it 'sends a notification to the user' do
        expect(NotificationClient).to have_received(:notify).with(
          task.id,
          user_id,
          'task_failed',
          hash_including(error: include('Não foi possível extrair'))
        )
      end
    end

    context 'when it fails (crash)' do
      before do
        allow(scraper_double).to receive(:scrape).and_raise(StandardError, 'Erro fatal no Selenium')

        described_class.perform_now(task.id)
        task.reload
      end

      it 'catch the error and update the task status to failed' do
        expect(task.status).to eq('failed')
      end

      it 'saves the error message in result_data' do
        expect(task.result_data['error']).to eq('Erro fatal no Selenium')
      end

      it 'sends a notification to the user' do
        expect(NotificationClient).to have_received(:notify).with(
          task.id,
          user_id,
          'task_failed',
          hash_including(error: 'Erro fatal no Selenium')
        )
      end
    end
  end
end