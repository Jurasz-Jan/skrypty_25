require 'mechanize'
require 'optparse'
require 'fileutils'

class AmazonCrawler
  SEARCH_URL = 'https://allegro.pl/listing?string=%{query}'

  def initialize(keyword: nil, url: nil)
    @keyword = keyword
    @url = url
    @agent = Mechanize.new
    @agent.user_agent_alias = 'Windows Chrome'
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
    # startujemy sesję, żeby Allegro dało ciastka sesyjne
    @agent.get('https://allegro.pl')

    # właściwe pobranie strony wyników
    page = @agent.get(url)
    Nokogiri::HTML(page.body)
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
