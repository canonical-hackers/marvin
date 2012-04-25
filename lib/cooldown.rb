module Cinch
  module Plugin
    module ClassMethods
      def cooldown
        if !$cooldown.nil? && $cooldown.key?(:config)
          hook(:pre, :for => [:match], :method => lambda {|m| cooldown_finished?(m)})
        end
      end
    end

    def cooldown_finished?(m)
      synchronize(:cooldown) do 
        if $cooldown[:config].key?(m.channel)
          if $cooldown.key?(:time)  
            if $cooldown[:config][m.channel] < (Time.now - $cooldown[:time]).floor
              $cooldown[:time] = Time.now
              return true
            else 
              debug "Cooldown: #{($cooldown[:config][m.channel] - (Time.now - $cooldown[:time])).floor}s"
              return false
            end
          else 
            $cooldown[:time] = Time.now
            return true
          end
        end
      end
    end
  end
end
