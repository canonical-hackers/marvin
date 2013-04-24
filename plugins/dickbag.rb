class Dickbag
  # This plugin is a recurring injoke in a specific open-minded and close-knit IRC Channel about a
  #   bag of takeout food from a burger joint called Dicks. I recreated this plugin to mimic the
  #   behavior of an older IRC bot.
  #
  #   I do not reccommend using this plugin. Ever. People will be offended at the _very_ least. :)

  include Cinch::Plugin

  self.help = "Use .dickbag to get the bag, you know you want some tasty, tasty Dicks."

  cooldown

  def initialize(*args)
    super
    @storage = Storage.new('yaml/dickbag.yaml')
    @storage.data[:dickbag] ||= Hash.new
    @storage.data[:stats]   ||= Hash.new
  end

  listen_to :channel

  set(:prefix => '')

  match /^[!\.]dickbag$/, method: :dickbag
  match /^[!\.](dickbag|db) info/, method: :info
  match /^[!\.](dickbag|db) stats/, method: :stats

  def listen(m)
    @storage.data[:dickbag][:current] = {} unless @storage.data[:dickbag].key?(:current)

    if m.user.nick == @storage.data[:dickbag][:current][:nick] &&
       m.action_message &&
       m.action_message.match(/(bag of dicks|dickbag)/)
      action = m.action_message.match(/^(.*) dickbag/)[1]
      if action.match(/noms|eats/)
        @storage.data[:dickbag][:last] = {:action => 'nom', :nick => m.user.nick}
        add_stats(m.user.nick, 0, @storage.data[:dickbag][:current][:time])
        @storage.data[:dickbag][:current] = Hash.new
      elsif action.match(/hides/)
        @storage.data[:dickbag][:last] = {:action => 'hid', :nick => m.user.nick}
        add_stats(m.user.nick, 0, @storage.data[:dickbag][:current][:time])
        @storage.data[:dickbag][:current] = Hash.new
      end

      synchronize(:save_dickbag) do
        @storage.save
      end
    end
  end

  def dickbag(m)
    if m.channel.nil?
      m.user.msg "You must use that command in the main channel."
      return
    end

    if @storage.data[:dickbag][:current].key?(:nick)
      if @storage.data[:dickbag][:current][:nick] == m.user.nick
        m.reply db_message('same_user'), true
      else
        m.channel.action db_message('new_owner', {:new => m.user.nick,
                                                  :old => @storage.data[:dickbag][:current][:nick]})
        add_stats(@storage.data[:dickbag][:current][:nick], 0, @storage.data[:dickbag][:current][:time])
        @storage.data[:dickbag][:current] = {:nick => m.user.nick, :time => Time.now,
                              :times_passed => @storage.data[:dickbag][:current][:times_passed] + 1 }
        add_stats(m.user.nick, 1)
      end
    elsif @storage.data[:dickbag].key?(:last)
      if @storage.data[:dickbag][:last][:action] == 'nom'
        m.channel.action db_message('nom', {:new => m.user.nick,
                                            :old => @storage.data[:dickbag][:last][:nick]})
        @storage.data[:dickbag][:current] = {:nick => m.user.nick, :time => Time.now, :times_passed => 0 }
      elsif @storage.data[:dickbag][:last][:action] == 'hid'
        m.channel.action db_message('hid', {:new => m.user.nick})
        @storage.data[:dickbag][:current] = {:nick => m.user.nick, :time => Time.now, :times_passed => 0 }
      end
      @storage.data[:dickbag][:last] = {}
      add_stats(m.user.nick, 1)
    else
      m.channel.action db_message('new', {:new => m.user.nick})
      @storage.data[:dickbag][:current] = {:nick => m.user.nick, :time => Time.now, :times_passed => 0 }
      add_stats(m.user.nick, 1)
    end

    synchronize(:save_dickbag) do
      @storage.save
    end

  end

  def stats(m)
    stats = []
    @storage.data[:stats].each_pair do |nick,info|
      stats << { :nick => nick, :time => info[:time], :count => info[:count] }
    end

    stats.sort! {|x,y| y[:count] <=> x[:count] }
    m.user.msg "Top 5 users by times they've had the bag:"
    stats[0..4].each_index do |i|
      m.user.msg "#{i + 1}. #{stats[i][:nick]} - #{stats[i][:count]}"
    end

    stats.sort! {|x,y| y[:time] <=> x[:time] }
    m.user.msg "Top 5 users by the total time they've had the bag:"
    stats[0..4].each_index do |i|
      m.user.msg "#{i + 1}. #{stats[i][:nick]} - #{time_format(stats[i][:time])}"
    end
  end

  def info(m)
    if @storage.data[:dickbag].key?(:current)
      if @storage.data[:dickbag][:current].key?(:nick)
        message = "#{@storage.data[:dickbag][:current][:nick]} is"
      else
        message = 'I am'
      end

      message << " currently holding the bag of dicks"

      if @storage.data[:dickbag][:current].key?(:time)
        message << ". I gave it to them #{@storage.data[:dickbag][:current][:time].ago.to_words}"
      end

      unless @storage.data[:dickbag][:current].key?(:times_passed)
        message << " and it's been shared by #{@storage.data[:dickbag][:current][:times_passed]} other people"
      end

      top = get_top_users

      unless top.nil?
        if top.key?(:count) && top.key?(:time) && top[:count][:nick] == top[:time][:nick]
          message << ". #{top[:count][:nick].capitalize} seems to love Dicks because they've held " +
                     "on to them more times (#{top[:count][:number]}) and " +
                     "for longer (#{time_format(top[:time][:number])}) than anyone else "
        elsif top.key?(:count) && top.key?(:time)
          message << ". So far, #{top[:count][:nick]} has had the bag the most times at #{top[:count][:number]}, " +
                     "while #{top[:time][:nick]} has held them for the longest time at  #{time_format(top[:time][:number])}"
        elsif top.key?(:count)
          message << ". So far, #{top[:count][:nick]} has had the bag the most times at #{top[:count][:number]}"
        elsif top.key?(:time)
          message << ". So far, #{top[time][:nick]} has held the bag for the longest time at #{time_format(top[:time][:number])}"
        end
      end
      message.strip!
      message << '.'
    else
      message = "no one seems to want my bag of dicks :("
    end
    m.reply message, true
  end

  def add_stats(user, count, time = nil)
    unless @storage.data[:stats].key?(user)
      @storage.data[:stats][user] = { :count => 0, :time => 0 }
    end

    @storage.data[:stats][user][:count] += count
    @storage.data[:stats][user][:time]  += (Time.now - time) unless time.nil?
  end

  def get_top_users
    counts = @storage.data[:stats].sort {|a,b| b[1][:count] <=> a[1][:count] }
    times = @storage.data[:stats].sort {|a,b| b[1][:time] <=> a[1][:time] }
    { :count => { :nick => counts.first[0], :number => counts.first[1][:count] },
      :time  => { :nick => times.first[0],  :number => times.first[1][:time] }}
  end

  def db_message(event, data = nil)
    case event
    when 'same_user'
      'you still have the bag of dicks. Chill the fuck out.'
    when 'new_owner'
      "reaches over to #{data[:old]}, takes the bag of dicks, and hands it to #{data[:new]}"
    when 'nom'
      "grabs a new bag of dicks for #{data[:new]} since #{data[:old]} went all nomnomonom on the last one."
    when 'hid'
      "grabs a new bag of dicks for #{data[:new]} since the last one seems to have vanished."
    when 'new'
      "reaches down and grabs a new bag of dicks and hands it to #{data[:new]}"
    end
  end

end
