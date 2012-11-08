class LogSearch
  include Cinch::Plugin
  cooldown

  self.help = "Use .search <text> to search the logs. *Only works via private message*, limited to 5 results for now."

  match /search (.*)/

  def execute(m, search)
    # Don't listen to searches in channels. Reduce SPAM. 
    return if m.channel?

    # However, make sure the user is in a channel with the bot
    chans = @bot.channels
    chans.delete_if { |chan| !chan.has_user?(m.user) } 
    return if chans.empty?

    @max_results = config[:search_max] || 5
    @matches = []  
    
    # Search the logs for the phrase, this is pretty simple.  
    Dir[File.join('.', 'logs', "*.log")].sort.reverse.each do |file| 
      @matches += File.open(file, 'r').grep(Regexp.new(search))
      # For the sake of sanity, stop looking once we find @max_results
      break if @matches.length > @max_results
    end
 
    # I hate new lines.  
    @matches.map! { |msg| msg.chomp } 

    if @matches.empty?
      m.user.msg "No matches found!"
    else
      msg = []
      msg << "Found #{@matches.count} matches"
      msg << "before giving up." if @matches.length > @max_results
      msg << "Here's the last #{@max_results}:"
      m.user.msg msg.join(' ')
      @matches[-@max_results..-1].each do |match| 
        m.user.msg match
      end
    end
  end
end
