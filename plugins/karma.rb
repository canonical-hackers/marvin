class Karma
  include Cinch::Plugin

  listen_to :channel
  match /karma (.+)/

  def initialize(*args)
    super
    @karma = {}
  end

  def listen(m)
    add = m.message.scan(/(\S+)\+\+/).map { |k| k.first }
    add.each do |k| 
      @karma[k] ? @karma[k] =+ 1 : @karma[k] = 1
    end

    sub = m.message.scan(/(\S+)\-\-/).map { |k| k.first }
    sub.each do |k| 
      @karma[k] ? @karma[k] =- 1 : @karma[k] = -1
    end
  end

  def execute(m, item)
    m.reply("Karma for #{item} is #{@karma[item] || '0' }")
  end 
end
