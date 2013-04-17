# -*- coding: utf-8 -*-
require 'rubygems'
require 'bundler/setup'
require 'yaml'

require 'cinch'
require 'cinch/logger'

# Load the bot config
conf = YAML::load(File.open('config/bot.yml'))

# Load Libs
Dir[File.join('.', 'lib', '*.rb')].each { |file| require file }
include Common

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
    if conf.key?('port')
      c.port       = conf['port']
    end

    # Plugins
    c.plugins.prefix  = '.'
    c.plugins.plugins = conf['plugins'].map { |plugin| Kernel.const_get(plugin) }

    # Setup bit.ly config, exit if not configured.
    if !conf.key?('bitly')
      puts "Please set your bit.ly info in conf/bot.yml if you want to use plugins that use url shortening."
      exit
    else
      c.shared = { :bitly => { :username => conf['bitly']['username'],
                               :apikey   => conf['bitly']['apikey'] } }
    end

    # Setup the cooldown if one is configured
    if conf.key?('cooldowns')
      c.shared[:cooldown] = { :config => conf['cooldowns'] }
    end

    # Link logger config
    if conf.key?('links')
      c.plugins.options[LinkLogger] = { :logonly      => conf['links']['logonly'],
                                        :twitter      => conf['links']['twitter'],
                                        :whitelist    => conf['links']['whitelist'],
                                        :reportstats  => conf['links']['reportstats'] }
    end

    # Tumblr config
    if conf.key?('tumblr')
      c.plugins.options[LinkLogger][:tumblr] = { :hostname  => conf['tumblr']['hostname'],
                                                 :tpass     => conf['tumblr']['tpass'] }
    end

    # Twitter config
    if conf.key?('twitter')
      c.plugins.options[LinkLogger][:twitter] = { :consumer_key    => conf['twitter']['consumer_key'],
                                                  :consumer_secret => conf['twitter']['consumer_secret'],
                                                  :oauth_token     => conf['twitter']['oauth_token'],
                                                  :oauth_secret    => conf['twitter']['oauth_secret'] }
    end


  end

  on :channel, /\A\.(help|status)\z/ do |m|
    m.reply "The following plugins are loaded: #{conf['plugins'].join(', ').downcase}. You can see their commands/usage by typing .help <plugin>."
  end

  on :channel, /\A\.stats\z/ do |m|
    if conf['stats_url']
      m.user.send "The stats for the channel are available at: #{conf['stats_url']}"
    else
      m.user.send "No stats page has been defined for this channel, sorry!"
    end
  end

  on :notice, /IDENTIFY/ do |m|
    if m.user.nick == 'NickServ'
      m.reply "IDENTIFY #{conf['nickserv_pass']}"
    end
  end
end

# Loggers
if conf.key?('logging')
  conf['logging'].each do |channel|
    @bot.loggers << Cinch::Logger::CanonicalLogger.new(channel, conf['nick'])
  end
end

@bot.start
