class PaxTimer
  include Cinch::Plugin
  require 'time-lord'
  cooldown

  match /(time|pax|timetillpax)\z/, method: :next_pax
  match /east|paxeast/, method: :next_east
  match /prime|paxprime/, method: :next_prime
  match /aus|paxaus/, method: :next_aus
  def initialize(*args)
    super
    @filename = 'config/pax.yml'
  end

  def next_pax(m)
    m.reply get_next_pax
  end

  ['east', 'aus', 'prime'].each do |pax_type|
    define_method "next_#{pax_type}" do |m|
      m.reply get_next_pax(pax_type)
    end
  end

  def get_next_pax(type = nil)
    if File::exist?(@filename)
      @paxes = YAML::load(File.open(@filename))

      @paxes.delete_if { |pax| pax[:date] - Time.now < 0 }
      @paxes.delete_if { |pax| pax[:type] != type } unless type.nil?
      @paxes.sort! { |a,b| b[:date] <=> a[:date] }

      @pax = @paxes.pop
      message = "#{@pax[:name]} is "
      message << 'approximately ' if @pax[:estimated]

      days = (@pax[:date] - Time.now) / 86400 # 86400 seconds in a day, etc.
      hours = (days - days.floor) * 24
      message << "#{days.floor} days "
      message << ", #{hours.floor} hours " if hours > 1 
      message << "away."
      message << " (No official date, yet)" if @pax[:estimated]
      return message
    else
      debug "[PAX] #{@filename} DOES NOT EXIST, PLEASE MAKE ONE"
      return
    end
  end
end
