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
        return true unless $cooldown[:config][m.channel]

        unless $cooldown[m.channel] 
          $cooldown[m.channel] = Time.now
          return true
        end

        cooldown = (Time.now - $cooldown[m.channel]).floor
        if $cooldown[:config][m.channel] < cooldown
          $cooldown[m.channel] = Time.now
          return true
        end

        time_left = $cooldown[:config][m.channel] - cooldown
        debug "Cooldown: #{time_left}s"

        m.user.notice "Sorry, you'll have to wait #{time_left} more seconds before I can talk in the channel again."
        return false
      end
    end
  end
end
