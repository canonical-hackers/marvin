class Sudo
  include Cinch::Plugin
  require 'file-tail'

  # this is the event that gets called when you join a channel
  listen_to 353

  def initialize(*args)
    super
    @date_re = Regexp.new(/^(\w{3}\s+\d+\s+\d{2}:\d{2}:\d{2})\s+/)
    @user_re = Regexp.new(/^sudo:\s+(\w+)\s+: /)
  end

  def listen(arg)
    # FIX: don't hard-code the channel name here
    target = Cinch::Target.new("#bottest", bot)

    File::Tail::Logfile.tail("/var/log/user.log") do |line|
      if looks_like_sudo? line
        target.msg process_line(line)
      end
    end
  end

  def looks_like_sudo?(line)
    if line =~ /sudo/
      true
    else
      false
    end
  end

  def process_line(line)
    date = line.match(@date_re)[1] || "(unknown timestamp)"
    line.gsub!(@date_re, "")

    # remove hostname
    line.gsub!(/^\w+\s/, "")

    # extract user
    user = line.match(@user_re)[1]
    line.gsub!(@user_re, '')

    sudo_fields = line.split(/ ; /)

    if sudo_fields.length == 4
      
    else
      
    end
  end
end
