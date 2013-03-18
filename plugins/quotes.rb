class Quotes
  include Cinch::Plugin
  cooldown

  self.help = "Use .quote <name> <quote> to store a quote, and .quote <name> to get a random one for that user."

  attr_accessor :storage

  match /quote (\w+) (.+)/, method: :add_quote
  match /quote (\w+)$/, method: :get_quote

  def initialize(*args)
    super
    @storage = Storage.new('yaml/quotes.yml')
    @storage.data[:quotes] ||= {}
  end

  def add_quote(m, user, text)
    debug "ADD"
    nick = m.user.nick
    unless @storage.data[:quotes].key?(nick)
      @storage.data[:quotes][user] = []
    end

    quote = { :added_by => nick,
              :quote => text,
              :time => Time.now }

    @storage.data[:quotes][user] << quote

    synchronize(:save_quotes) do
      @storage.save
    end
  end

  def get_quote(m, nick)
    debug "GET"
    return unless @storage.data[:quotes].key?(nick)
    quotes = @storage.data[:quotes][nick]
    q = quotes[rand(quotes.length)]
    m.reply "<#{nick}> #{q[:quote]}"
    debug "GET"
  end
end

