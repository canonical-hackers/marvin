class Karma
  include Cinch::Plugin

  listen_to :channel
  self.help = 'Use .karma <item> to see it\'s karma level. You can use <item>++ or <item>-- [or (something with spaces)++] to alter karma for an item'
  cooldown

  match /karma (.+)/
  match /k (.+)/

  def initialize(*args)
    super
    @storage = Storage.new('yaml/karma.yml')
  end

  def listen(m)
    if m.message.match(/\S+[\+\-]{2}/)
      channel = m.channel.name
      @storage.data[channel] = Hash.new unless @storage.data.key?(channel)
      updated = false

      m.message.scan(/.*?((\w+)|\((.+?)\))(\+\+|--)(\s|\z)/).each do |karma|
        debug "#{karma}"
        if karma[0]
          item = karma[1] || karma[2]
          @storage.data[channel][item] = 0 unless @storage.data[channel].key?(item)

          if karma[3] == '++'
            @storage.data[channel][item] += 1
            updated = true
          elsif karma[3] == '--'
            @storage.data[channel][item] -= 1
            updated = true
          else
            debug 'something went wrong matching karma!'
          end
        end
      end

      if updated
        synchronize(:karma_save) do
          @storage.save
        end
      end
    end
  end

  def execute(m, item)
    if m.channel.nil?
      m.user.msg "You must use that command in the main channel."
      return
    end

    @storage.data[m.channel.name] = Hash.new unless @storage.data.key?(m.channel.name)
    karma = @storage.data[m.channel.name][item] || 0
    m.reply("Karma for #{item} is #{karma}")
  end
end
