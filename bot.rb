# -*- coding: utf-8 -*-
require 'rubygems'
require 'bundler/setup'

require 'cinch'
require 'cinch-logger-canonical'

require 'cinch-calculate'
require 'cinch-convert'
require 'cinch-dicebag'
require 'cinch-karma'
require 'cinch-logsearch'
require 'cinch-magic'
require 'cinch-seen'
require 'cinch-links-logger'
require 'cinch-links-titles'
require 'cinch-twitterstatus'
require 'cinch-weatherman'
require 'cinch-urbandict'
require 'cinch-wikipedia'

# Load the bot config
conf = YAML::load(File.open('config/bot.yml'))

# Init Bot
@bot = Cinch::Bot.new do
  configure do |c|
    # Base Config
    c.nick         = conf[:nick]
    c.server       = conf[:server]
    c.channels     = conf[:chans].map { |chan| "##{chan}" }
    c.max_messages = 1
    c.port         = conf[:port] if conf.key?(:port)

    # Plugins
    c.plugins.prefix  = '.'
    c.plugins.plugins = Cinch::Plugins.constants.map { |c| Class.module_eval("Cinch::Plugins::#{c}") }

    # Link logger config
    if conf.key?(:links)
      c.plugins.options[Cinch::Plugins::LinksLogger] = conf[:links]
    end

    # Twitter config
    if conf.key?(:twitter)
      c.plugins.options[Cinch::Plugins::TwitterStatus] = conf[:twitter]
    end
  end
end

# Loggers
if conf.key?(:logging)
  conf[:logging].each do |channel|
    @bot.loggers << Cinch::Logger::CanonicalLogger.new(channel, @bot)
  end
end

@bot.start
