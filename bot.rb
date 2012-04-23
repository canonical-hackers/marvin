require 'cinch'
require 'rubygems'
require 'active_record'
require 'yaml'
#require 'resolv-replace'

# Init Active record 
@@bitlyconfig = YAML::load(File.open('config/bitly.yml'))
dbconfig =    YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

# Load misc files 
Dir[File.join('.', 'lib', '*.rb')].each { |file| require file } 

# Load Plugins
Dir[File.join('.', 'plugins', '*.rb')].each { |file| require file }

bot = Cinch::Bot.new do
  configure do |c|
    c.nick    = 'marvin'
    c.server  = 'irc.canonical.org'
    c.channels = ["#bottest"]
    c.plugins.plugins = [ Dice, 
                          Karma, 
                          Seen, 
                          TitleLookup, 
                          UrbanDictionary, 
                          Wikipedia ]
  end
end

bot.start
