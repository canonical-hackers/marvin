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
    c.plugins.plugins = [
                          Cinch::Plugins::Calculate,
                          Cinch::Plugins::Convert,
                          Cinch::Plugins::Dicebag,
                          Cinch::Plugins::Karma,
                          Cinch::Plugins::LinksLogger,
                          Cinch::Plugins::LogSearch,
                          Cinch::Plugins::Magic,
                          Cinch::Plugins::Seen,
                          Cinch::Plugins::TwitterStatus,
                          Cinch::Plugins::Weatherman,
                          Cinch::Plugins::Wikipedia,
                          Cinch::Plugins::UrbanDict
                        ]

    # Setup the cooldown if one is configured
    if conf.key?(:cooldowns)
      c.shared[:cooldown] = { :config => conf[:cooldowns] }
    end

    # Link logger config
    if conf.key?(:links)
      #c.plugins.options[Cinch::Plugins::LinksLogger] = conf[:links]
    end

    # Link logger config
    if conf.key?(:gameclub)
      c.plugins.options[Cinch::Plugins::Gameclub] = conf[:gameclub]
    end

    # Tumblr config
    if conf.key?(:tumblr)
    #  c.plugins.options[Cinch::Plugins::LinksTumblr] = conf[:tumblr]
    end

    # Twitter config
    if conf.key?(:twitter)
    #  c.plugins.options[Cinch::Plugins::TwitterStatus] = conf[:twitter]
    end


  end

  on :channel, /\A\.stats\z/ do |m|
    if conf['stats_url']
      m.user.send "The stats for the channel are available at: #{conf[:stats_url]}"
    else
      m.user.send "No stats page has been defined for this channel, sorry!"
    end
  end

  on :notice, /IDENTIFY/ do |m|
    if m.user.nick == 'NickServ'
      m.reply "IDENTIFY #{conf[:nickserv_pass]}"
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
