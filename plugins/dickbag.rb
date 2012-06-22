class Dickbag
  # This plugin is a recurring injoke in a specific open minded close knit IRC Channel. 
  #   I do not reccommend using this plugin. Ever. People will be offended at the very least. 

  include Cinch::Plugin

  cooldown
    
  def initialize(*args)
    super
    @storage = Storage.new('yaml/dickbag.yaml')
    @storage.data[:dickbag] ||= Hash.new
    @storage.data[:stats]   ||= Hash.new
  end

  self.help = "Use .dickbag to get the bag, I don't really want to know why you want it so bad."
  listen_to :channel

  set(:prefix => '') 

  match /^[!\.]dickbag$/, method: :dickbag
  match /^[!\.]dickbag info/, method: :info    

  def listen(m)
    @storage.data[:dickbag][:current] = {} unless @storage.data[:dickbag].key?(:current)
    
    if m.user.nick == @storage.data[:dickbag][:current][:nick] && 
       m.action_message && 
       m.action_message.match(/(bag of dicks|dickbag)/)
      action = m.action_message.match(/^(.*) dickbag/)[1]
      if action.match(/noms/)
        @storage.data[:dickbag][:last] = {:action => 'nom', :nick => @storage.data[:dickbag][:current][:nick]}  
        @storage.data[:dickbag][:current] = Hash.new
      elsif action.match(/hides/)
        @storage.data[:dickbag][:last] = {:action => 'hid', :nick => @storage.data[:dickbag][:current][:nick]}  
        @storage.data[:dickbag][:current] = Hash.new 
      end  

      synchronize(:save_dickbag) do
        @storage.save
      end
    end
  end

  def dickbag(m)
    if @storage.data[:dickbag][:current].key?(:nick)
      if @storage.data[:dickbag][:current][:nick] == m.user.nick
        m.reply "you still have the bag of dicks. Chill the fuck out.", true
      else 
        m.channel.action "reaches over to #{@storage.data[:dickbag][:current][:nick]}, takes the bag of dicks, and hands it to #{m.user.nick}"
        @storage.data[:dickbag][:current] = {:nick => m.user.nick, :time => Time.now, 
                              :times_passed => @storage.data[:dickbag][:current][:times_passed] + 1 } 
        add_dick(m.user.nick)
      end   
    elsif @storage.data[:dickbag].key?(:last)
      if @storage.data[:dickbag][:last][:action] == 'nom'
        m.channel.action "grabs a new bag of dicks for #{m.user.nick} since #{@storage.data[:dickbag][:last][:nick]} went all nomnomonom on the last one."
        @storage.data[:dickbag][:current] = {:nick => m.user.nick, :time => Time.now, :times_passed => 0 }
      elsif @storage.data[:dickbag][:last][:action] == 'hid'
        m.channel.action "grabs a new bag of dicks for #{m.user.nick} since the last one seems to have vanished."
        @storage.data[:dickbag][:current] = {:nick => m.user.nick, :time => Time.now, :times_passed => 0 }
      end  
      @storage.data[:dickbag][:last] = {} 
      add_dick(m.user.nick)
    else  
      m.channel.action "reaches down and grabs a new bag of dicks and hands it to #{m.user.nick}"
      @storage.data[:dickbag][:current] = {:nick => m.user.nick, :time => Time.now, :times_passed => 0 }
      add_dick(m.user.nick)
    end

    synchronize(:save_dickbag) do
      @storage.save
    end

  end

  def info(m)
    if @storage.data[:dickbag].key?(:current)
      message = "#{@storage.data[:dickbag][:current][:nick]} is currently holding the bag of dicks"

      if @storage.data[:dickbag][:current].key?(:time)
        message << ". I gave it to them #{@storage.data[:dickbag][:current][:time].ago_in_words}"
      end 

      unless @storage.data[:dickbag][:current][:times_passed] == 0
        message << " and #{@storage.data[:dickbag][:current][:times_passed]} other people have had their filthy hands all over them"
      end

      message << '.'
    else
      message = "no one seems to want my bag of dicks :("
    end
    m.reply message, true
  end

  def add_dick(user)
    if @storage.data[:stats].key?(user)
      @storage.data[:stats][user] += 1
    else
      @storage.data[:stats][user] = 1
    end
  end
end
