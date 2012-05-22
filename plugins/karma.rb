class Karma
  include Cinch::Plugin

  listen_to :channel
  self.help = 'Use .karma <item> to see the karma level for <item>. You can use <item>++ or <item>-- to alter karma for an item'
  cooldown

  match /karma (.+)/
  match /k (.+)/

  def initialize(*args)
    super
    @storage = Storage.new('yaml/karma.yml')
  end

  def listen(m)
    if m.message.match(/(\S+)[\+\-]{2}/) 
      
      channel = m.channel.name  
      @storage.data[channel] = Hash.new unless @storage.data.key?(channel) 
      
      add = m.message.scan(/(\S+)[^\-\+]\+{2}\s/).map { |k| k.first }
      add.each do |k|
        @storage.data[channel][k] = 0 unless @storage.data[channel].key?(k)
        @storage.data[channel][k] += 1
      end

      sub = m.message.scan(/(\S+)[^\-\+]\-{2}\s/).map { |k| k.first }
      sub.each do |k|
        @storage.data[channel][k] = 0 unless @storage.data[channel].key?(k)
        @storage.data[channel][k] -= 1
      end

      if add || sub
        synchronize(:karma_save) do 
          @storage.save
        end
      end 
    end
  end

  def execute(m, item)
    karma = @storage.data[m.channel][item] || 0
    m.reply("Karma for #{item} is #{karma}")
  end

  private 


end
