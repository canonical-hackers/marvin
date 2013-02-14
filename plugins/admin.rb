class Admin
  include Cinch::Plugin

  # Due to how not so secure this is don't add any real channel admin stuff here.
  # Limit these commands to simple non destructive bot commands

  match /join (.+)/, method: :join
  match /part(?: (.+))?/, method: :part
  match /goaway|bye|reboot/, method: :shutdown

  def initialize(*args)
    super
    @admins = ['asmer', 'paulv']
  end

  def check_user(user)
    user.refresh # be sure to refresh the data, or someone could steal
                 # the nick
    @admins.include?(user.nick.downcase)
  end

  def join(m, channel)
    return unless check_user(m.user)
    Channel(channel).join
  end

  def part(m, channel)
    return unless check_user(m.user)
    channel ||= m.channel
    Channel(channel).part if channel
  end

  def shutdown(m)
    return unless check_user(m.user)
    @bot.quit
  end
end

