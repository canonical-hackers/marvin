class Dickbag
  # This plugin is a recurring injoke in a specific open minded close knit IRC Channel. 
  #   I do not reccommend using this plugin. Ever. People will be offended at the very least. 

  include Cinch::Plugin
    
  def initialize(*args)
    super
    @owner = {} 
  end

  listen_to :channel
  match /dickbag$/, method: :steal
  match /dickbag info/, method: :info    

  def listen(m)
    if m.user.nick == @owner[:nick] && m.action_message.match(/the\sbag\sof\sdicks/)
      case m.action_message.match(/(\S+)\sthe\sbag\sof\sdicks/)[1]
      when 'eats'
        m.channel.action "recoils in horror as #{@owner[:nick]} gobbles down the bag of dicks!"
        @owner = {}
      when 'hides'
        m.channel.action "looks confused as #{@owner[:nick]} hides the bag of dicks in their pants."
      end  
    end
  end

  def steal(m)
    if @owner.key?(:nick)
      if @owner[:nick] == m.user.nick
        m.reply "you still have the bag of dicks, chill the fuck out.", true
      else 
        m.channel.action "reaches over to #{@owner[:nick]} steals the bag and hands it to #{m.user.nick}"
        @owner = {:nick => m.user.nick, :time => Time.now, :times_passed => @owner[:times_passed] + 1 } 
      end 
    else 
      m.channel.action "reaches down and grabs a new bag of dicks and hands it to #{m.user.nick}"
      @owner = {:nick => m.user.nick, :time => Time.now, :times_passed => 0 } 
    end
  end

  def info(m)
    if @owner.key?(:nick)
      message = "#{@owner[:nick]} is currently holding the bag of dicks, they stole it #{@owner[:time].ago_in_words}"
      if @owner[:times_passed] > 0 
        message += "and #{@owner[:times_passed]} other people have had their filthy hands all over them."
      else 
        message += '.'
      end 
    else
      message = "no one seems to want my bag of dicks :("
    end
    m.reply message, true
  end
end
