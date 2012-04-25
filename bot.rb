require "rubygems"
require "bundler/setup"
require 'yaml'
require 'cinch'

# Define an array that we can do help stuff, might be a better way to do this.
$commands = Hash.new('Command not found')
config = YAML::load(File.open("config/#{ARGV[0] || 'bot'}.yml"))

# Setup the cooldown if one is configured
$cooldown = { :config => config['cooldowns'] } if config['cooldowns']

# Load misc files
Dir[File.join('.', 'lib', '*.rb')].each { |file| require file }

# Load Plugins
Dir[File.join('.', 'plugins', '*.rb')].each { |file| require file }


@bot = Cinch::Bot.new do
  configure do |c|
    c.nick         = config['nick']
    c.server       = config['server']
    c.channels     = config['chans']
    c.max_messages = 1
    c.plugins.prefix   = '.'
    c.plugins.plugins = config['plugins'].map { |plugin| Kernel.const_get(plugin) }
  end

  on :channel, /^.help/ do |m|
    command = m.message.match(/^.help (.*)/)[1] rescue nil
    if command
      m.reply $commands[command], true
    else
      m.reply "The following help topics are available: #{$commands.keys.join(', ')}."
    end
  end
end

@bot.start
