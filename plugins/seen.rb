class Seen
  require 'time-lord'
  include Cinch::Plugin

  listen_to :channel
  self.help = "Use .seen <name> to see the last time that nick was active."
  
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
      m.reply("I last saw #{nick} #{@seen[nick.downcase].ago_in_words}", true)
    else
      m.reply("I've never seen #{nick} before, sorry!", true)
    end
  end
end

