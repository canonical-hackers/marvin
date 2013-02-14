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
    if @pax[:prime] < Time.now
      east(m)
    elsif @pax[:east] < Time.now
      prime(m)
    else
      @pax[:east] > @pax[:prime] ? prime(m) : east(m)
    end
  end

  def east(m)
    m.reply time_left('PAX East', @pax[:east])
  end

  def prime(m)
    m.reply time_left('PAX Prime', @pax[:prime])
  end

  def time_left(name, time)
    return name + " has already passed for this year!" unless (time - Time.now) > 0
    days = (time - Time.now) / 86400 # 86400 seconds in a day, etc.
    hours = (days - days.floor) * 24
    "#{name} is #{days.floor} days#{hours > 1 ? ", #{hours.floor} hours " : ''}away."
  end
end
