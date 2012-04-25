class Seen
  include Cinch::Plugin

  listen_to :channel
  help = "Use .seen <name> to see the last time that nick was active."
  
  match /seen (.+)/

  def initialize(*args)
    super
    @seen = {}
  end

  def listen(m)
    @seen[m.user.nick.downcase] = Time.now
  end

  def execute(m, nick)
    if @seen[nick.downcase]
      m.reply("I last saw #{nick} #{@seen[nick.downcase].strftime("%b %e @ %H:%M")}", true)
    else
      m.reply("I've never seen #{nick} before, sorry!", true)
    end
  end
end

