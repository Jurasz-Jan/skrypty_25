require 'open-uri'
require 'nokogiri'
require 'optparse'
require 'fileutils'

class AmazonCrawler
  SEARCH_URL = 'https://allegro.pl/listing?string=%{query}'
  USER_AGENT = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:125.0) Gecko/20100101 Firefox/125.0',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15'
  ].freeze

  def initialize(keyword: nil, url: nil)
    @keyword = keyword
    @url = url
  end

  def run
    doc = fetch(start_url)
    products = parse_list(doc)
    write_to_file(products)
    puts "Saved #{products.size} products."
  end

  private

  def start_url
    @url || SEARCH_URL % { query: URI.encode_www_form_component(@keyword) }
  end

  def fetch(url)
    retries = 0
    max_retries = 3

    begin
      headers = {
        'User-Agent' => USER_AGENT.sample,
        'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language' => 'pl-PL,pl;q=0.8,en-US;q=0.5,en;q=0.3',
        'Connection' => 'keep-alive',
        'Upgrade-Insecure-Requests' => '1',
        'Referer' => 'https://allegro.pl/'
      }

      response = URI.open(url, headers)
      Nokogiri::HTML(response)
    rescue OpenURI::HTTPError, SocketError, Timeout::Error => e
      if retries < max_retries
        retries += 1
        delay = 2 ** retries
        puts "⚠️ Error: #{e.message}. Retrying in #{delay}s (attempt #{retries}/#{max_retries})"
        sleep delay
        retry
      else
        puts "❌ Fatal error after #{max_retries} attempts: #{e.message}"
        exit(1)
      end
    end
  end

  def parse_list(doc)
    doc.css('article').map do |item|
      title = item.at_css('h2 a')&.text&.strip
      link = item.at_css('h2 a')&.[]('href')
      price = item.at_css('span._1svub._lf05o')&.text&.strip

      puts "Found: #{title} | #{price} | #{link}"

      next unless title && link

      {
        title: title,
        price: price || "N/A",
        link: link
      }
    end.compact
  end

  def write_to_file(products)
    FileUtils.mkdir_p('./data')
    File.open('./data/products.txt', 'w') do |file|
      products.each do |prod|
        file.puts("#{prod[:title]} | #{prod[:price]} | #{prod[:link]}")
      end
    end
  end
end

if __FILE__ == $0
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: ruby amazon_crawler.rb [options]"
    opts.on('-k', '--keyword WORD', 'Search keyword') { |v| options[:keyword] = v }
    opts.on('-u', '--url URL', 'Direct URL') { |v| options[:url] = v }
  end.parse!

  unless options[:keyword] || options[:url]
    puts "Please provide search keyword with -k"
    exit
  end

  crawler = AmazonCrawler.new(keyword: options[:keyword], url: options[:url])
  crawler.run
end