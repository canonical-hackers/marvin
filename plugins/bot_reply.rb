class BotReply
  require 'yaml'
  include Cinch::Plugin
  cooldown

  def initialize(bot)
    super
    @quotes = YAML::load(File.open('config/quotes.yml'))
  end

  set(:prefix => '')
  match /^(\S+):/
    
  def execute(m, nick)
    # Only reply if the bot was messaged 
    if nick == m.bot.nick
      # Load the quotes file on first use, should do this in init, but I can't
      #  figure out how to get the bot name in that scope.
      quotes = @quotes[nick]
      debug "#{@quotes.length} - #{m.bot.nick}"

      debug m.bot.nick 
      if quotes.nil? || quotes.empty? 
        debug "No quotes defined for bot named #{nick}"
      else 
        m.reply quotes[rand(quotes.length)], true
      end
    end
  end
end 
