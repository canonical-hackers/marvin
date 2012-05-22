# -*- coding: utf-8 -*-
require 'rubygems'
require 'bundler/setup'
require 'yaml'

require 'cinch'
require 'cinch/logger'

# Load the bot config 
conf = YAML::load(File.open("config/#{ARGV[0] || 'bot'}.yml"))

# Setup the cooldown if one is configured
$cooldown = { :config => conf['cooldowns'] } if conf.key?('cooldowns')

# Load Libs
Dir[File.join('.', 'lib', '*.rb')].each { |file| require file }

# Load Plugins
Dir[File.join('.', 'plugins', '*.rb')].each { |file| require file }

# Init Bot
@bot = Cinch::Bot.new do
  configure do |c|
    # Base Config
    c.nick         = conf['nick']
    c.server       = conf['server']
    c.channels     = conf['chans'].map { |chan| '#' + chan } 
    c.max_messages = 1

    # Plugins 
    c.plugins.prefix  = '.'
    c.plugins.plugins = conf['plugins'].map { |plugin| Kernel.const_get(plugin) }
    
    # Link logger config 
    if conf.key?('links')
      c.plugins.options[LinkLogger][:logonly]     = conf['links']['logonly']
      c.plugins.options[LinkLogger][:whitelist]   = conf['links']['whitelist']
      c.plugins.options[LinkLogger][:reportstats] = conf['links']['reportstats']
    end 

    # Tumblr config 
    if conf.key?('tumblr')
      c.plugins.options[LinkLogger][:tumblr] = { :username => conf['tumblr']['username'], 
                                                 :password => conf['tumblr']['password'],  
                                                 :group    => conf['tumblr']['group'],
                                                 :tpass    => conf['tumblr']['tpass'] } 
    end
  end

  on :channel, /\a\.(help|status)\Z/ do |m|
    m.reply "The following plugins are loaded: #{conf['plugins'].join(', ')}."
  end
end

# Loggers
if conf.key?('logging')
  conf['logging'].each do |channel| 
    @bot.loggers << Cinch::Logger::CanonicalLogger.new(channel, conf['nick'])
  end
end
   
@bot.start
