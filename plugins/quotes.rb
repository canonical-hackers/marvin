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
    nick = m.user.nick

    unless @storage.data[:quotes].key?(user.downcase)
      @storage.data[:quotes][user.downcase] = []
    end

    quote = { :added_by => nick,
              :canonical_nick => user,
              :quote => text,
              :time => Time.now }

    @storage.data[:quotes][user.downcase] << quote

    synchronize(:save_quotes) do
      @storage.save
    end
  end

  def get_quote(m, nick)
    nick.downcase!
    return unless @storage.data[:quotes].key?(nick)
    quotes = @storage.data[:quotes][nick]
    q = quotes[rand(quotes.length)]
    m.reply "<#{q[:canonical_nick]}> #{q[:quote]}"
  end
end

