require 'rubygems'
require 'bundler/setup'
require 'yaml'
require 'cinch'

# Load Libs
Dir[File.join('.', 'lib', '*.rb')].each { |file| require file }
Dir[File.join('.', 'plugins', '*.rb')].each { |file| require file }

def fake_bot
  bot = Cinch::Bot.new
  bot.loggers.level = :fatal
  return bot
end

def rand_string(size=16)
  (1..size).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
end

module Cinch
  module Plugin
    def initialize(opts = {})
      @bot = fake_bot 
      @handlers = []
      @timers   = []
      # Lets try not initing the bot 
      # __register
    end
  end
end
