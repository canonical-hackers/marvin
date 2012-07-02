require 'rspec/given'
require_relative 'helpers.rb'

describe Sudo do
  def bot_with_fatal_logger
    bot = Cinch::Bot.new
    bot.loggers.level = :fatal
    bot
  end

  context "looks like sudo: test 1" do
    Given(:sudo) { Sudo.new(bot_with_fatal_logger) }
    When(:looks_like) { sudo.looks_like_sudo?("Apr 23 13:15:03 panacea sudo: fsfzones : TTY=unknown ; PWD=/home/fsfzones ; USER=root ; COMMAND=/usr/sbin/invoke-rc.d bind9 reload") }
    Then { looks_like.should == true }
  end

  context "looks like sudo: test 2" do
    Given(:sudo) { Sudo.new(bot_with_fatal_logger) }
    When(:looks_like) { sudo.looks_like_sudo?("Apr 18 02:04:11 panacea sudo: pam_unix(sudo:auth): conversation failed") }
      Then { looks_like.should == false }
  end

  context "looks like sudo: test 3" do
    Given(:sudo) { Sudo.new(bot_with_fatal_logger) }
    When(:looks_like) { sudo.looks_like_sudo?("Apr 30 17:59:12 panacea sshd[14284]: Failed password for sudo from 222.87.204.13 port 40829 ssh2") }
    Then { looks_like.should == false }
  end

  context "test 1" do
    Given(:sudo) { Sudo.new(bot_with_fatal_logger) }
    When(:sudo_results) { sudo.process_line("Apr 23 13:15:03 panacea sudo: fsfzones : TTY=unknown ; PWD=/home/fsfzones ; USER=root ; COMMAND=/usr/sbin/invoke-rc.d bind9 reload") }
    Then { sudo_results.date.should == "Apr 23 13:15:03" }
    Then { sudo_results.user.should == "fsfzones" }
    Then { sudo_results.tty.should  == "unknown" }
    Then { sudo_results.pwd.should  == "/home/fsfzones" }
    Then { sudo_results.executed_as.should  == "root" }
    Then { sudo_results.command.should  == "/usr/sbin/invoke-rc.d bind9 reload" }
    Then { sudo_results.success.should == true }
  end

  context "test 2" do
    Given(:sudo) { Sudo.new(bot_with_fatal_logger) }
    When(:sudo_results) { sudo.process_line("Apr 18 02:23:32 panacea sudo:     jrbl : TTY=pts/38 ; PWD=/home/jrbl/.spamassassin ; USER=root ; COMMAND=/bin/chgrp spamd bayes_toks") }
    Then { sudo_results.date.should == "Apr 18 02:23:32" }
    Then { sudo_results.user.should == "jrbl" }
    Then { sudo_results.tty.should  == "pts/38" }
    Then { sudo_results.pwd.should  == "/home/jrbl/.spamassassin" }
    Then { sudo_results.executed_as.should  == "root" }
    Then { sudo_results.command.should  == "/bin/chgrp spamd bayes_toks" }
    Then { sudo_results.success.should == true }
  end

  context "test 3" do
    Given(:sudo) { Sudo.new(bot_with_fatal_logger) }
    When(:sudo_results) { sudo.process_line("Apr 24 03:12:39 panacea sudo:    paulv : 3 incorrect password attempts ; TTY=pts/6 ; PWD=/home/paulv ; USER=root ; COMMAND=/bin/ls -l /tmp") }
    Then { sudo_results.date.should == "Apr 24 03:12:39" }
    Then { sudo_results.user.should == "paulv" }
    Then { sudo_results.tty.should  == "pts/6" }
    Then { sudo_results.pwd.should  == "/home/paulv" }
    Then { sudo_results.executed_as.should  == "root" }
    Then { sudo_results.command.should  == "/bin/ls -l /tmp" }
    Then { sudo_results.success.should  == false }
  end
end
