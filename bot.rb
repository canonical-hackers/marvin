require "rubygems"
require "bundler/setup"
require 'yaml'
require 'cinch'

# Load the bot config 
config = YAML::load(File.open("config/#{ARGV[0] || 'bot'}.yml"))

# Setup the cooldown if one is configured
$cooldown = { :config => config['cooldowns'] } if config['cooldowns']

# Load Libs
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
    c.plugins.options[LinkLogger][:whitelist] = config['links']['whitelist']
    c.plugins.options[LinkLogger][:reportstats] = config['links']['reportstats']
  end
end

@bot.start
