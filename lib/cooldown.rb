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

        debug "Cooldown: #{$cooldown[:config][m.channel] - cooldown}s"
        return false
      end
    end
  end
end
