require 'rubygems'
require 'active_record'
require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'bitly'

Dir[File.join('lib', '*.rb')].each do |file| 
  require file
end

# Init Active record 
dbconfig =    YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

# Init the URL shortener
bitlyconfig = YAML::load(File.open('config/bitly.yml'))
Bitly.use_api_version_3
@bitly = Bitly.new(bitlyconfig["username"], bitlyconfig["api_key"])

require 'ponder'

@ponder = Ponder::Thaum.new do |thaum|
  thaum.nick    = 'katherine'
  thaum.server  = 'irc.canonical.org'
  thaum.port    = 6667
  thaum.logging = true
end

@ponder.on :connect do
  @ponder.join '#bottest'
end

def get_page_element(url, css_path)
  # Make sure the URL is legit 
  url = URI::extract(url, ["http", "https"]).first

  # Grab the element
  Nokogiri::HTML(open(url)).css(css_path).first.content
end

def shorten(url)
  @bitly.shorten(url)
end

@ponder.on :channel, /(https?:\/\/[\S]+)/ do |event|
  url = event[:message].gsub(/(https?:\/\/[\S]+)/, '\1')
  title = get_page_element(url, 'title')
  @ponder.message event[:channel], "#{shorten(url)} .:. #{title || 'Untitled'}"
end 

@ponder.on :channel, /^.ud (.*)/ do |event|
  term = event[:message].gsub(/^.ud (.*)/, '\1')
  
  definition = get_page_element("http://www.urbandictionary.com/define.php?term=#{term}", 
                                '.definition')
  @ponder.message event[:channel], 
                  "Urban Dictionary .:. #{term}: #{definition || 'Definition not found'}" 
end

@ponder.connect

