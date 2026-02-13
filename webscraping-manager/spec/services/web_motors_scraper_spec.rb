require 'rails_helper'

RSpec.describe WebMotorsScraper do
  let(:url) { 'https://www.webmotors.com.br/teste' }
  subject { described_class.new(url) }

  let(:driver_double) { double("Selenium::WebDriver::Remote::Driver") }
  let(:navigation_double) { double("Selenium::WebDriver::Navigation") }

  before do
    allow(Selenium::WebDriver::Chrome::Options).to receive(:new).and_return(double.as_null_object)

    allow(Selenium::WebDriver).to receive(:for).and_return(driver_double)

    allow(driver_double).to receive(:execute_cdp)
    allow(driver_double).to receive(:navigate).and_return(navigation_double)
    allow(navigation_double).to receive(:to)
    allow(driver_double).to receive(:quit)
    allow(driver_double).to receive(:page_source).and_return("<html></html>")
  end

  describe '#scrape' do
    context 'quando a página carrega o JSON oficial (__NEXT_DATA__)' do
      let(:json_data) do
        {
          props: {
            pageProps: {
              vehicle: {
                Make: { Value: 'Honda' },
                Model: { Value: 'Civic 2.0' },
                Prices: { Price: 'R$ 150.000' }
              }
            }
          }
        }.to_json
      end

      let(:html_with_json) do
        <<-HTML
          <html>
            <head><title>Honda Civic</title></head>
            <body>
              <script id="__NEXT_DATA__">#{json_data}</script>
            </body>
          </html>
        HTML
      end

      before do
        allow(driver_double).to receive(:page_source).and_return(html_with_json)
      end

      it 'extrai os dados prioritariamente via JSON' do
        result = subject.scrape

        expect(result[:brand]).to eq('Honda')
        expect(result[:model]).to eq('Civic 2.0')
        expect(result[:price]).to eq('R$ 150.000')
        expect(result[:note]).to eq('Via JSON Oficial')
      end

      it 'fecha o driver ao final' do
        subject.scrape
        expect(driver_double).to have_received(:quit)
      end
    end

    context 'quando o JSON falha, mas o HTML visual (CSS) funciona' do
      let(:html_only_css) do
        <<-HTML
          <html>
            <head><title>Comprar Honda Civic</title></head>
            <body>
              <h1 class="model-title">
                Honda
                <span class="model-subtitle">Civic LXR</span>
              </h1>
              <div id="vehicle-price">R$ 80.000</div>
            </body>
          </html>
        HTML
      end

      before do
        allow(driver_double).to receive(:page_source).and_return(html_only_css)
      end

      it 'extrai os dados via seletores CSS' do
        result = subject.scrape

        expect(result[:brand]).to eq('Honda')
        expect(result[:model]).to eq('Honda Civic LXR')
        expect(result[:price]).to eq('R$ 80.000')

        expect(result[:note]).to eq('Dados extraídos via CSS (Layout Catálogo)')
      end
    end

    context 'quando ocorre um bloqueio do PerimeterX (Erro 403)' do
      let(:html_blocked) do
        <<-HTML
          <html>
            <head><title>403 Forbidden</title></head>
            <body>
              <h1>Access to this page has been denied</h1>
            </body>
          </html>
        HTML
      end

      before do
        allow(driver_double).to receive(:page_source).and_return(html_blocked)
      end

      it 'levanta uma exceção específica de bloqueio' do
        expect {
          subject.scrape
        }.to raise_error(RuntimeError, /BLOQUEIO CRÍTICO/)
      end

      it 'ainda tenta fechar o driver mesmo com erro' do
        begin
          subject.scrape
        rescue RuntimeError
        end
        expect(driver_double).to have_received(:quit)
      end
    end

    context 'quando o driver do Selenium falha (ex: Timeout ou Crash)' do
      before do
        allow(navigation_double).to receive(:to).and_raise(StandardError, 'Net::ReadTimeout')
      end

      it 'loga o erro e relança a exceção' do
        expect(Rails.logger).to receive(:error).with(/Erro Scraper: Net::ReadTimeout/)

        expect {
          subject.scrape
        }.to raise_error(StandardError, 'Net::ReadTimeout')
      end

      it 'garante o fechamento do driver no ensure' do
        begin
          subject.scrape
        rescue StandardError
        end
        expect(driver_double).to have_received(:quit)
      end
    end
  end
end