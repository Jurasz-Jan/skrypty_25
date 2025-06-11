require 'open-uri'
require 'nokogiri'
require 'sequel'
require 'optparse'

DB = Sequel.sqlite('products.db')

DB.create_table? :products do
  primary_key :id
  String :title
  String :price
  String :link
  Text :details
end

class AmazonCrawler
  SEARCH_URL = 'https://www.amazon.com/s?k=%{query}'

  def initialize(keyword: nil, url: nil)
    @keyword = keyword
    @url = url
  end

  def run
    doc = fetch(start_url)
    products = parse_list(doc)
    products.each do |prod|
      prod[:details] = fetch_details(prod[:link])
      save_product(prod)
      puts "Saved #{prod[:title]}"
    end
  end

  private

  def start_url
    @url || SEARCH_URL % { query: URI.encode_www_form_component(@keyword) }
  end

  def fetch(url)
    html = URI.open(url, 'User-Agent' => 'Mozilla/5.0').read
    Nokogiri::HTML(html)
  end

  def parse_list(doc)
    doc.css('div.s-result-item').map do |item|
      title = item.at_css('h2 a span')&.text
      price = item.at_css('span.a-offscreen')&.text
      link = item.at_css('h2 a')&.[]('href')
      next unless title && price && link
      {
        title: title.strip,
        price: price.strip,
        link: URI.join('https://www.amazon.com', link).to_s
      }
    end.compact
  end

  def fetch_details(url)
    doc = fetch(url)
    doc.at_css('#productDescription')&.text&.strip || ''
  rescue StandardError => e
    warn "Failed to fetch details from #{url}: #{e.message}"
    ''
  end

  def save_product(prod)
    DB[:products].insert(prod)
  end
end

if __FILE__ == $0
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: ruby amazon_crawler.rb [options]"
    opts.on('-k', '--keyword WORD', 'Search keyword') { |v| options[:keyword] = v }
    opts.on('-u', '--url URL', 'Direct Amazon URL') { |v| options[:url] = v }
  end.parse!

  crawler = AmazonCrawler.new(keyword: options[:keyword], url: options[:url])
  crawler.run
end
