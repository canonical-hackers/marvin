class Karma
  include Cinch::Plugin

  listen_to :channel

  cooldown

  $commands['karma'] = 'Use .karma <item> to see the karma level for <item>. You can use <item>++ or <item>-- to alter karma for an item'

  match /karma (.+)/
  match /k (.+)/

  def initialize(*args)
    super
    @karma = Hash.new(0)
  end

  def listen(m)
    add = m.message.scan(/(\S+)\+\+/).map { |k| k.first }
    add.each do |k|
      @karma[k] += 1
    end

    sub = m.message.scan(/(\S+)\-\-/).map { |k| k.first }
    sub.each do |k|
      @karma[k] -= 1
    end
  end

  def execute(m, item)
    m.reply("Karma for #{item} is #{@karma[item]}")
  end
end
