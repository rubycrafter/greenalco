require 'open-uri'
require 'nokogiri'
require 'scraperwiki'

class Parser
  attr_accessor :url, :tag, :doc, :headers, :catalog

  def initialize
    @tag = Hash.new
    @url = 'http://greenalco.ru'
    @tag[:main_category] = '.box-category ul li a'
    @tag[:group_item] = '.box-category ul li a'
    @doc = Nokogiri::HTML(open(url))
    @headers = %w(name paramsynonym category currency price discount description briefdescription)
    @catalog = []
    configure_scraper
  end

  def call
    add_header
    groups = scan_main_page
    groups.each do |group|
      scan_group(group)
    end
  end

  private

  def add_record(arr)
    @catalog << arr
    save_to_sqlite(arr)
  end

  def add_header
    add_record(@headers)
  end

  def scan_main_page
    scan_menu
  end

  def scan_menu
    groups = Hash.new
    @doc.css(@tag[:main_category]).each do |row|
      groups[row.content] = row['href']
    end

    groups
  end

  def scan_group(group)
  end

  def scan_item(item)
  end

  def configure_scraper
    ScraperWiki.config = { db: 'data.sqlite', default_table_name: 'data' }
  end

  def save_to_sqlite(arr)
    ScraperWiki.save_sqlite(arr, Hash[@headers.zip arr])
  end
end

Parser.new.call
