module Cinch
  module Plugin
    module ClassMethods
      def cooldown
        if !$cooldown.nil? && $cooldown.key?(:timer)
          hook(:pre, :for => [:match], :method => lambda {|m| cooldown_finished?(m)})
        end
      end
    end

    def cooldown_finished?(m)
      synchronize(:cooldown) do 
        if $cooldown.key?(:time)
          if $cooldown[:timer] < (Time.now - $cooldown[:time]).floor
            $cooldown[:time] = Time.now
            true
          else 
            false
          end
        else 
          $cooldown[:time] = Time.now
          true
        end
      end
    end
  end
end
