class Seen
  require 'time-lord'
  include Cinch::Plugin

  listen_to :channel
  self.help = "Use .seen <name> to see the last time that nick was active."
  
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
    if @storage.data[:seen][m.channel.name].key?(nick.downcase)
      m.reply "I last saw #{nick} #{@storage.data[:seen][m.channel.name][nick.downcase].ago_in_words}", true
    else
      m.reply "I've never seen #{nick} before, sorry!", true
    end
  end
end

