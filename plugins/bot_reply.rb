class BotReply
  require 'yaml'
  include Cinch::Plugin

  def initialize(*args)
    super
    @quotes = YAML::load(File.open('config/quotes.yml'))
  end

  set(:prefix => '')
  match /^(\S+):/

  def execute(m, nick)
    if nick == m.bot.nick
      quotes = @quotes[nick]
      if quotes.nil? || quotes.empty?
        debug "No quotes defined for bot named #{nick}"
      else
        m.reply quotes[rand(quotes.length)], true
      end
    end
  end
end
