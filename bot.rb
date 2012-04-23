require 'cinch'
require 'rubygems'
#require 'active_record'
require 'yaml'

#@bitlyconfig = YAML::load(File.open('config/bitly.yml'))
# dbconfig =     YAML::load(File.open('config/database.yml'))
# ActiveRecord::Base.establish_connection(dbconfig)

# Define an array that we can do help stuff, might be a better way to do this. 
$commands = Hash.new('Command not found') 

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
    @quotes = YAML::load(File.open('config/marvin.yml'))['quotes']
    m.reply @quotes[rand(@quotes.length)], true
  end

  on :message, /^!help/ do |m|
    command = m.message.match(/^!help (.*)/)[1] rescue nil
    if command 
      m.reply $commands[command], true
    else
      m.reply "The following help topics are available: #{$commands.keys.join(', ')}."
    end
  end

end

@bot.start
