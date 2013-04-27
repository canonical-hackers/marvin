class Seen
  require 'time-lord'
  include Cinch::Plugin

  cooldown

  listen_to :channel
  self.help = "Use .seen <name> to see the last time that nick was active."
  attr_accessor :storage

  match /seen (.+)/

  def initialize(*args)
    super
    @storage = Storage.new('yaml/seen.yml')
    @storage.data[:seen] ||= {}
  end

  def listen(m)
    @storage.data[:seen][m.channel.name] = {} unless @storage.data[:seen].key?(m.channel.name)
    @storage.data[:seen][m.channel.name][m.user.nick.downcase] = Time.now
    synchronize(:seen_save) do
      @storage.save
    end
  end

  def execute(m, nick)
    if m.channel.nil?
      m.user.msg "You must use that command in the main channel."
      return
    end

    unless m.user.nick == nick.downcase
      if @storage.data[:seen][m.channel.name].key?(nick.downcase)
        m.reply "I last saw #{nick} #{@storage.data[:seen][m.channel.name][nick.downcase].ago.to_words}", true
      else
        m.reply "I've never seen #{nick} before, sorry!", true
      end
    end
  end
end

