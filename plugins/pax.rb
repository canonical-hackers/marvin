class PaxTimer
  include Cinch::Plugin
  require 'time-lord'
  cooldown

  match /time|pax|timetillpax/

  def initialize(*args) 
    super 
    @pax = { :name => 'PAX Prime', :time => Time.local(2012, 8, 31, 7) } 
  end 

  def execute(m)
    days = (@pax[:time] - Time.now) / (60 * 60 * 24)
    hours = (days - days.floor) * 24 
    m.reply "#{@pax[:name]} is #{days.floor} days#{hours > 1 ? ", #{hours.floor} hours " : ''}away."
  end
end
