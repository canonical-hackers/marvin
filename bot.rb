require "rubygems"
require "bundler/setup"
require 'yaml'
require 'cinch'
require 'cinch/storage/yaml'
#require 'active_record'

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
  config = YAML::load(File.open('config/bot.yml'))
  configure do |c|
    c.nick     = config['nick']
    c.server   = config['server']
    c.channels = config['chans']
    c.plugins.plugins = config['plugins'].map { |plugin| Kernel.const_get(plugin) }
    # Storage seems to be half baked, commenting this out till it's working.
    #c.storage.backend = Cinch::Storage::YAML
    #c.storage.basedir = "./db/"
    #c.storage.autosave = true
  end

  on :message, /^marvin:/ do |m|
    @quotes = YAML::load(File.open('config/quotes.yml'))
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
