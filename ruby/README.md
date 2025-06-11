# Ruby Web Crawler

This directory contains an example web crawler written in Ruby. The crawler
uses Nokogiri to parse HTML from Amazon product listings and stores basic
information about each product in an SQLite database using Sequel.

## Requirements

- Ruby >= 2.7
- `nokogiri` gem
- `sequel` gem
- `sqlite3` gem

Install dependencies:

```bash
bundle install
```

Run the crawler with a search term:

```bash
ruby amazon_crawler.rb "laptop"
```

Data will be saved to `products.db`.

## Running with Docker

You can also run the crawler inside a Docker container (useful on Windows).
Build the image and pass crawler options directly to `docker run`:

```bash
docker build -t amazon_crawler .
docker run --rm amazon_crawler -k laptop
```

To persist the SQLite database on the host, mount a volume:

```bash
docker run --rm -v %cd%/data:/app amazon_crawler -k laptop
```
