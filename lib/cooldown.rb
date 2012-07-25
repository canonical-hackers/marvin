module Cinch
  module Plugin
    module ClassMethods
      def cooldown
        if $cooldown && $cooldown[:config]
          hook(:pre, :for => [:match], :method => lambda {|m| cooldown_finished?(m)})
        end
      end
    end

    def cooldown_finished?(m)
      synchronize(:cooldown) do
        channel = m.channel.name
        nick = m.user.nick 

        return true unless $cooldown[:config][channel]
        
        unless $cooldown.key?(channel)
          $cooldown[channel] = { 'global' => Time.now, nick => Time.now } 
          return true
        end

        if channel_cooldown_finished?(channel)
          # Global cd is up, check per user 
          if $cooldown[channel].key?(nick) 
            # User's in the config, check time
            if user_cooldown_finished?(channel, nick)
              $cooldown[channel]['global'] = Time.now
              $cooldown[channel][nick] = Time.now
              return true
            end
          else 
            # User's not used bot before
            $cooldown[channel][nick] = Time.now
            $cooldown[channel]['global'] = Time.now
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
      $cooldown[:config][chan]['user']   < user_time_elapsed(chan, user)
    end

    def channel_cooldown_finished?(chan)
      $cooldown[:config][chan]['global'] < channel_time_elapsed(chan)
    end 

    def channel_time_remaining(chan)
      $cooldown[:config][chan]['global'] - channel_time_elapsed(chan)
    end

    def user_time_remaining(chan, user) 
      $cooldown[:config][chan]['user'] - user_time_elapsed(chan, user)
    end

    def channel_time_elapsed(chan)
      (Time.now - $cooldown[chan]['global']).floor
    end

    def user_time_elapsed(chan, user) 
      (Time.now - $cooldown[chan][user]).floor
    end
  end
end
