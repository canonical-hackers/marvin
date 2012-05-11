class Dickbag
  # This plugin is a recurring injoke in a specific open minded close knit IRC Channel. 
  #   I do not reccommend using this plugin. Ever. People will be offended at the very least. 

  include Cinch::Plugin

  cooldown
    
  def initialize(*args)
    super
    @dickbag = {}
  end

  self.help = "Use .dickbag to get the bag, I don't really want to know why you want it so bad."
  listen_to :channel

  set(:prefix => '') 

  match /^[!\.]dickbag$/, method: :dickbag
  match /^[!\.]dickbag info/, method: :info    

  def listen(m)
    @dickbag[:current] = {} unless @dickbag.key?(:current)
    
    if m.user.nick == @dickbag[:current][:nick] && m.action_message && m.action_message.match(/bag of dicks|dickbag/)
      action = m.action_message.match(/^(.*) dickbag/)[1]
      if action.match(/noms/)
        @dickbag[:last] = {:action => 'nom', :nick => @dickbag[:current][:nick]}  
        @dickbag[:current] = Hash.new
      elsif action.match(/hides/)
        @dickbag[:last] = {:action => 'hid', :nick => @dickbag[:current][:nick]}  
        @dickbag[:current] = Hash.new 
      end  
    end
  end

  def dickbag(m)
    if @dickbag[:current].key?(:nick)
      if @dickbag[:current][:nick] == m.user.nick
        m.reply "you still have the bag of dicks. Chill the fuck out.", true
      else 
        m.channel.action "reaches over to #{@dickbag[:current][:nick]} takes the bag of dicks and hands it to #{m.user.nick}"
        @dickbag[:current] = {:nick => m.user.nick, :time => Time.now, 
                              :times_passed => @dickbag[:current][:times_passed] + 1 } 
      end   
    elsif @dickbag.key?(:last)
      if @dickbag[:last][:action] == 'nom'
        m.channel.action "grabs a new bag of dicks for #{m.user.nick} since #{@dickbag[:last][:nick]} went all nomnomonom on the last one."
        @dickbag[:current] = {:nick => m.user.nick, :time => Time.now, :times_passed => 0 }
      elsif @dickbag[:last][:action] == 'hid'
        m.channel.action "grabs a new bag of dicks for #{m.user.nick} since the last one seems to have vanished."
        @dickbag[:current] = {:nick => m.user.nick, :time => Time.now, :times_passed => 0 }
      end
    else  
      m.channel.action "reaches down and grabs a new bag of dicks and hands it to #{m.user.nick}"
      @dickbag[:current] = {:nick => m.user.nick, :time => Time.now, :times_passed => 0 }
    end
  end

  def info(m)
    if @dickbag.key?(:current)
      message = "#{@dickbag[:current][:nick]} is currently holding the bag of dicks"

      if @dickbag[:current].key?(:time)
        message << ", they stole it #{@dickbag[:current][:time].ago_in_words}"
      end 

      unless @dickbag[:current][:times_passed] == 0
        message << " and #{@dickbag[:current][:times_passed]} other people have had their filthy hands all over them"
      end

      message << '.'
    else
      message = "no one seems to want my bag of dicks :("
    end
    m.reply message, true
  end
end
