class PaxTimer
  include Cinch::Plugin
  require 'time-lord'
  cooldown

  match /(time|pax|timetillpax)\z/, method: :next_pax
  match /east|paxeast/, method: :east
  match /prime|paxprime/, method: :prime


  def initialize(*args) 
    super 
    @pax = { :prime => Time.local(2012, 8, 31, 7),
             :east  => Time.local(2013, 3, 22, 4) }
  end 

  def next_pax(m)
    @pax[:east] < @pax[:prime] ? east(m) : prime(m)
  end

  def east(m)
    days = (@pax[:east] - Time.now) / (60 * 60 * 24)
    hours = (days - days.floor) * 24 
    m.reply "PAX East is #{days.floor} days#{hours > 1 ? ", #{hours.floor} hours " : ''}away."
  end

  def prime(m)
    days = (@pax[:prime] - Time.now) / (60 * 60 * 24)
    hours = (days - days.floor) * 24 
    m.reply "PAX Prime is #{days.floor} days#{hours > 1 ? ", #{hours.floor} hours " : ''}away."
  end
end
