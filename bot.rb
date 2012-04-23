require 'cinch'
require 'rubygems'
require 'active_record'
require 'yaml'
require 'ruby-bitly'

# Init Active record 
@bitlyconfig = YAML::load(File.open('config/bitly.yml'))
dbconfig =     YAML::load(File.open('config/database.yml'))
@quotes =      YAML::load(File.open('config/marvin.yml'))['quotes']
ActiveRecord::Base.establish_connection(dbconfig)

# Load misc files 
Dir[File.join('.', 'lib', '*.rb')].each { |file| require file } 

# Load Plugins
Dir[File.join('.', 'plugins', '*.rb')].each { |file| require file }

@bot = Cinch::Bot.new do
  configure do |c|
    c.nick    = 'marvin'
    c.server  = 'irc.canonical.org'
    c.channels = ["#bottest"]
    c.plugins.plugins = [ Admin,
                          Dice, 
                          Karma, 
                          Seen, 
                          TitleLookup, 
                          UrbanDictionary, 
                          Wikipedia ]
  end

  on :message, /^marvin:/ do |m|
    m.reply @quotes[rand(@quotes.length)], true
  end

  helpers do
    def shorten(url)
      return Bitly.shorten(url, @bitlyconfig['username'], @bitlyconfig['apikey']).url
    end
  end

end

@bot.start
