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
      c.plugins.options[LinkLogger][:tumblr] = { :username => conf['tumblr']['username'], 
                                                 :password => conf['tumblr']['password'],  
                                                 :group    => conf['tumblr']['group'],
                                                 :tpass    => conf['tumblr']['tpass'] } 
    end
  end

  on :channel, /\A\.(help|status)\z/ do |m|
    m.reply "The following plugins are loaded: #{conf['plugins'].join(', ').downcase}. You can see their commands/usage by typing .help <plugin>."
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
