class LogSearch
  include Cinch::Plugin
  cooldown

  match /search (.*)/

  def execute(m, search)
    @matches = []  
    Dir[File.join('.', 'logs', "*.log")].reverse.each do |file| 
      @matches += File.open(file, 'r').grep(Regexp.new(search))
      break if @matches.length > 10
    end
  
    debug m.message

    @matches.map! { |msg| msg.chomp } 

    if @matches.empty?
      m.user.msg "No matches found!"
    else
      msg = []
      msg << "Found #{@matches.count} matches"
      msg << "before giving up." if @matches.length > 10
      msg << "Here's the last 10:"
      m.user.msg msg.join(' ')
      @matches[-10..-1].each do |msg| 
        m.user.msg msg
      end
    end
  end
end
