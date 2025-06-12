require 'open-uri'
require 'nokogiri'
require 'fileutils'
require 'logger'
require 'securerandom'

# Define a simple Product struct for better data encapsulation
Product = Struct.new(:title, :price, :link)

class AmazonCrawler
  BASE_URL = 'https://www.amazon.com/s?k=laptop'
  
  # Fixed headers as requested
  USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/109.0'
  ACCEPT_LANGUAGE = 'en-US,en;q=0.5'
  ACCEPT_ENCODING = 'gzip, deflate, br'
  ACCEPT = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8'
  REFERER = 'http://www.google.com/'

  def initialize
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @cookies = {}
  end

  def run
    FileUtils.mkdir_p('./data')

    @logger.info "Starting Amazon crawling from #{BASE_URL}"

    doc = fetch(BASE_URL)
    return unless doc

    products = parse_list(doc)
    write_to_file(products)

    @logger.info "Successfully saved #{products.size} products to ./data/Amazon_products.txt"
  rescue StandardError => e
    @logger.error "An error occurred during crawling: #{e.message}\n#{e.backtrace.join("\n")}"
  end

  private

  def fetch(url)
    # Precisely matching the requested headers
    headers = {
      'User-Agent' => USER_AGENT,
      'Accept' => ACCEPT,
      'Accept-Language' => ACCEPT_LANGUAGE,
      'Accept-Encoding' => ACCEPT_ENCODING,
      'Referer' => REFERER,
      'Connection' => 'keep-alive',
      'DNT' => '1',
      'Upgrade-Insecure-Requests' => '1',
      'Sec-Fetch-Dest' => 'document',
      'Sec-Fetch-Mode' => 'navigate',
      'Sec-Fetch-Site' => 'cross-site',
      'Sec-Fetch-User' => '?1',
      'Cache-Control' => 'max-age=0',
      'TE' => 'trailers'
    }
    
    # Add cookies if available
    headers['Cookie'] = @cookies.map { |k, v| "#{k}=#{v}" }.join('; ') unless @cookies.empty?

    begin
      # Human-like random delay
      delay = rand(2.0..5.0)
      @logger.info "Delaying #{delay.round(2)} seconds before request..."
      sleep(delay)

      @logger.debug "Fetching: #{url}"
      response = URI.open(url, headers)
      
      # Store cookies for subsequent requests
      save_cookies(response.meta['set-cookie'])
      
      # Handle compressed content
      content = handle_encoding(response)
      
      Nokogiri::HTML(content)
    rescue OpenURI::HTTPError => e
      @logger.error "HTTP Error: #{e.message} [#{e.io.status.join(' ')}]"
      nil
    rescue StandardError => e
      @logger.error "Request failed: #{e.message}"
      nil
    end
  end

  def save_cookies(cookie_header)
    return unless cookie_header
    
    cookie_header.split(/,\s*(?=[^;]+;)/).each do |cookie|
      next unless cookie.include?('=')
      key, value = cookie.split('=', 2)
      key.strip!
      value = value.split(';').first.strip
      @cookies[key] = value
    end
    @logger.debug "Stored cookies: #{@cookies.keys.join(', ')}"
  end

  def handle_encoding(response)
    case response.meta['content-encoding']
    when 'gzip'
      Zlib::GzipReader.new(StringIO.new(response.read)).read
    when 'deflate'
      Zlib::Inflate.inflate(response.read)
    when 'br'
      # Fallback to plain text if Brotli not available
      defined?(Brotli) ? Brotli.inflate(response.read) : response.read
    else
      response.read
    end
  end

  def parse_list(doc)
    # Zmieniamy selektor głównych elementów na `div.s-result-item`
    doc.css('div.s-result-item').map do |item|
      # Link do produktu zawiera tytuł, więc szukamy go najpierw
      # Wybiera pierwszy link, który ma klasy sugerujące link do produktu
      # Możesz potrzebować doprecyzować ten selektor, jeśli na stronie są inne linki z tymi klasami
      link_elem = item.at_css('a.a-link-normal.s-line-clamp-2') ||
                  item.at_css('a.a-link-normal.s-no-outline') # Dla linku z obrazkiem

      link = link_elem&.[]('href')

      # Tytuł jest w <span> wewnątrz <h2>, który jest wewnątrz znalezionego linku
      title_elem = link_elem&.at_css('h2 span')
      title = title_elem&.text&.strip

      # Cena jest w span z klasą a-offscreen wewnątrz span.a-price
      price_elem = item.at_css('span.a-price > span.a-offscreen')
      price = price_elem&.text&.strip || "N/A" # Cena na Amazonie może być w USD

      # Amazon ma często linki względne (np. /nazwa-produktu/dp/ASIN), więc dodajemy bazowy URL
      # W przypadku sponsorowanych linków URL jest bardzo długi i już pełny
      if link && !link.start_with?('http')
         # Czasem linki sponsorowane są już pełne, musisz sprawdzić
         # Jeśli link zaczyna się od "/sspa/click", to jest pełny URL Amazona
         # Jeśli link zaczyna się od "/nazwa/dp/", to jest względny
        if link.start_with?('/sspa/click')
          link = "https://www.amazon.com#{link}" # Dodajemy domenę
        else
          link = URI.join('https://www.amazon.com', link).to_s if link
        end
      end


      @logger.debug "Found: #{title} | #{price} | #{link}"

      if title && link && price != "N/A" # Sprawdzamy też, czy cena nie jest "N/A"
        Product.new(title, price, link)
      else
        missing_parts = []
        missing_parts << "No title" unless title
        missing_parts << "No link" unless link
        missing_parts << "No price" if price == "N/A"
        @logger.warn "Skipping incomplete product: #{title || 'Unknown Title'} | #{missing_parts.join(', ')}"
        nil
      end
    end.compact
  end


  def write_to_file(products)
    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    filename = "./data/amazon_products_#{timestamp}.txt" # Zmień nazwę pliku na Amazon
    File.open(filename, 'w') do |file|
      products.each do |prod|
        file.puts("#{prod[:title]} | #{prod[:price]} | #{prod[:link]}")
      end
    end
  end
end

# Run the crawler
AmazonCrawler.new.run