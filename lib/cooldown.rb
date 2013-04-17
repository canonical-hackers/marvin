module Cinch
  module Plugin
    module ClassMethods
      def cooldown
        hook(:pre, :for => [:match], :method => lambda {|m| cooldown_finished?(m)})
      end
    end

    def cooldown_finished?(m)
      return true unless shared[:cooldown] && shared[:cooldown][:config]
      synchronize(:cooldown) do
        return true if m.channel.nil?

        channel = m.channel.name
        nick = m.user.nick

        return true unless shared[:cooldown][:config][channel]

        unless shared[:cooldown].key?(channel)
          shared[:cooldown][channel] = { 'global' => Time.now, nick => Time.now }
          return true
        end

        if channel_cooldown_finished?(channel)
          # Global cd is up, check per user
          if shared[:cooldown][channel].key?(nick)
            # User's in the config, check time
            if user_cooldown_finished?(channel, nick)
              shared[:cooldown][channel]['global'] = Time.now
              shared[:cooldown][channel][nick] = Time.now
              return true
            end
          else
            # User's not used bot before
            shared[:cooldown][channel][nick] = Time.now
            shared[:cooldown][channel]['global'] = Time.now
            return true
          end
        end


        message = "Sorry, you'll have to wait "
        unless channel_cooldown_finished?(channel)
          message << "#{time_format(channel_time_remaining(channel))} before I can talk in the channel again, and "
        end
        message << "#{time_format(user_time_remaining(channel, nick))} before your nick can use any commands."

        m.user.notice message
        return false
      end
    end

    def user_cooldown_finished?(chan, user)
      shared[:cooldown][:config][chan]['user']   < user_time_elapsed(chan, user)
    end

    def channel_cooldown_finished?(chan)
      shared[:cooldown][:config][chan]['global'] < channel_time_elapsed(chan)
    end

    def channel_time_remaining(chan)
      shared[:cooldown][:config][chan]['global'] - channel_time_elapsed(chan)
    end

    def user_time_remaining(chan, user)
      shared[:cooldown][:config][chan]['user'] - user_time_elapsed(chan, user)
    end

    def channel_time_elapsed(chan)
      (Time.now - shared[:cooldown][chan]['global']).floor
    end

    def user_time_elapsed(chan, user)
      (Time.now - shared[:cooldown][chan][user]).floor
    end
  end
end
