module Cinch
  module Plugin
    module ClassMethods
      def cooldown
        if !$cooldown.nil? && $cooldown.key?(:timer)
          hook(:pre, :for => [:match], :method => lambda {|m| cooldown_finished?(m)})
          hook(:post, :for => [:match], :method => lambda {|m| reset_cooldown(m) }) 
        end
      end
    end

    def cooldown_finished?(m)
      if $cooldown.key?(:time)
        if $cooldown[:timer] < (Time.now - $cooldown[:time]).floor
          $cooldown[:time] = Time.now
          return true
        else 
          debug "Command dropped due to cooldown: #{m.message} #{$cooldown[:timer] - (Time.now - $cooldown[:time])} seconds left before commands are accepted."
          return false 
        end
      else 
        true
      end
    end

    def reset_cooldown(m)
      debug "Resetting Cooldown"
    end
  end
end
