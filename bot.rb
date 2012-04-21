require 'cinch'
require 'rubygems'
require 'active_record'
require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'bitly'
require 'cgi'

# Load Plugins
Dir[File.join('.', 'plugins', '*.rb')].each do |file| 
  require file
end

# Init Active record 
dbconfig =    YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)


# Init the URL shortener
bitlyconfig = YAML::load(File.open('config/bitly.yml'))
Bitly.use_api_version_3
@bitly = Bitly.new(bitlyconfig["username"], bitlyconfig["api_key"])

bot = Cinch::Bot.new do
  configure do |c|
    c.nick    = 'katherine'
    c.server  = 'irc.canonical.org'
    c.channels = ["#bottest"]
    c.plugins.plugins = [UrbanDictionary, TitleLookup]
  end
end

bot.start
