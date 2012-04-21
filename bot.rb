require 'cinch'
require 'rubygems'
require 'active_record'
require 'yaml'
require 'bitly'

# Init Active record 
dbconfig =    YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

# Load misc files 
Dir[File.join('.', 'lib', '*.rb')].each { |file| require file } 

# Load Plugins
Dir[File.join('.', 'plugins', '*.rb')].each { |file| require file }

# Init the URL shortener
bitlyconfig = YAML::load(File.open('config/bitly.yml'))
Bitly.use_api_version_3
@bitly = Bitly.new(bitlyconfig["username"], bitlyconfig["api_key"])

bot = Cinch::Bot.new do
  configure do |c|
    c.nick    = 'katherine'
    c.server  = 'irc.canonical.org'
    c.channels = ["#bottest"]
    c.plugins.plugins = [UrbanDictionary, TitleLookup, Seen]
  end
end

bot.start
