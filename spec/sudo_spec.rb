require 'cinch'
require 'cinch/plugin'
require 'file-tail'
require_relative '../plugins/sudo'

describe Sudo do
  def bot_with_fatal_logger
    bot = Cinch::Bot.new
    bot.loggers.level = :fatal
    bot
  end

  it "should correctly parse normal lines logged by sudo" do
    sudo = Sudo.new(bot_with_fatal_logger)
    correct_results = {
      :date => "Apr 23 13:15:03",
      :user => "fsfzones",
      :tty => "unknown",
      :pwd => "/home/fsfzones",
      :executed_as => "root",
      :command => "/usr/sbin/invoke-rc.d bind9 reload",
    }
    generated_results = sudo.process_line("Apr 23 13:15:03 panacea sudo: fsfzones : TTY=unknown ; PWD=/home/fsfzones ; USER=root ; COMMAND=/usr/sbin/invoke-rc.d bind9 reload")
    generated_results.should == correct_results
  end
end
