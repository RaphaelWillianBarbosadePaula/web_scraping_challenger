require 'nokogiri'
require 'selenium-webdriver'
require 'json'

class WebMotorsScraper
  def initialize(url)
    @url = url
  end

  def scrape
    options = Selenium::WebDriver::Chrome::Options.new

    # --- Configurações de Navegador (Linux Profile) ---
    options.add_argument('--headless=new')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1920,1080')
    options.add_argument('--lang=pt-BR')

    options.add_argument('user-agent=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36')

    # --- Evasão Padrão ---
    options.exclude_switches << 'enable-automation'
    options.add_argument('--disable-blink-features=AutomationControlled')

    selenium_url = ENV.fetch('SELENIUM_URL', 'http://chrome:4444/wd/hub')
    driver = Selenium::WebDriver.for(:remote, url: selenium_url, options: options)

    begin
      driver.execute_cdp('Page.addScriptToEvaluateOnNewDocument', source: <<-JS)
        Object.defineProperty(navigator, 'webdriver', { get: () => undefined });
        Object.defineProperty(navigator, 'plugins', { get: () => [1, 2, 3] });
        Object.defineProperty(navigator, 'languages', { get: () => ['pt-BR', 'pt', 'en-US'] });
      JS
    rescue => e
      Rails.logger.warn "Aviso CDP: #{e.message}"
    end

    begin
      driver.navigate.to @url
      sleep 5

      html = driver.page_source
      doc = Nokogiri::HTML(html)

      # Verificação de falha crítica
      if doc.title.to_s.include?("403") || doc.text.include?("Access to this page has been denied")
         raise "BLOQUEIO CRÍTICO: O Webmotors detectou a automação."
      end

      script_tag = doc.at_css('script[id="__NEXT_DATA__"]')
      if script_tag
        data = extract_from_json(script_tag.content) rescue nil
        return data if data
      end

      data = extract_from_css(doc)
      return data if data

      extract_from_meta_tags(doc)

    rescue StandardError => e
      Rails.logger.error "Erro Scraper: #{e.message}"
      raise e
    ensure
      driver.quit if driver
    end
  end

  private
    def extract_from_json(json_content)
    data = JSON.parse(json_content)
    vehicle = data.dig('props', 'pageProps', 'vehicle')

    raise "Veículo não encontrado no JSON" unless vehicle

    {
      brand: vehicle.dig('Make', 'Value'),
      model: vehicle.dig('Model', 'Value'),
      price: vehicle.dig('Prices', 'Price'),
      note: "Via JSON Oficial"
    }
  end

  def extract_from_css(doc)
    h1 = doc.at_css('h1.model-title')
    if h1
      brand_text = h1.children.find { |c| c.text? }&.text&.strip
      model_text = h1.at_css('.model-subtitle')&.text&.strip
      raw_title = "#{brand_text} #{model_text}".strip
    else
      raw_title = doc.at_css('h1')&.text&.strip ||
                  doc.at_css('.main-info__text-content h2')&.text&.strip ||
                  doc.title&.split('|')&.first&.strip
    end

    return nil unless raw_title

    clean_title = raw_title.gsub(/^(Conheça\s+[ao]\s+|Comprar\s+)/i, '').strip
    brand_guess = clean_title.split(' ').first

    price = doc.at_css('.main-info__text--price-value')&.text&.strip ||
            doc.at_css('[data-testid="main-info__text--price-value"]')&.text&.strip ||
            doc.at_css('#vehicle-price')&.text&.strip

    {
      brand: brand_guess,
      model: clean_title,
      price: price,
      note: "Dados extraídos via CSS (Layout Catálogo)"
    }
  end

  def extract_from_meta_tags(doc)
    title = doc.at_css('meta[property="og:title"]')&.[]('content')
    description = doc.at_css('meta[property="og:description"]')&.[]('content')

    {
      title_collected: title,
      description_collected: description,
      note: "Via Meta Tags (Fallback)"
    }
  end
end