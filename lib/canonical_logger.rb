require "cinch/logger"
module Cinch
  class Logger
    class CanonicalLogger < Cinch::Logger
      # (see Logger#log)
      def log(messages, event = :debug, level = event)
        return unless will_log?(level)

        @mutex.synchronize do
          # Ensure that we're logging to the right file. 
          Array(messages).each do |message|
            next unless message.match(Regexp.new("PRIVMSG ##{@channel}"))           
            message = format_general(message)
            message = format_message(message, event)

            next if message.nil?
            sync_logfile
            @output.puts message.encode("locale", {:invalid => :replace, :undef => :replace})
          end
        end
      end
      
      def initialize(channel, bot)
        @bot_name = bot
        @channel  = channel
        @output   = File.open(today_log, 'a')
        @output.sync = true
        @mutex    = Mutex.new
        @level    = :debug
      end

      private

      def today_log
        "./logs/#{@channel}_#{Time.now.strftime("%Y-%m-%d")}.log"
      end

      def format_incoming(message)
        nick = message.match(/^:(\S+)!/)[1] rescue 'NONICK'
        msg  = message.match(/#\S+ :(.+)$/)[1] rescue 'NOMSG'
        generic_format(nick, msg)
      end

      def format_outgoing(message)
        msg = message.match(/#\S+ :(.+)$/)[1] rescue 'NOMSG'
        generic_format(@bot_name, msg)
      end

      def generic_format(nick, m) 
        message = '[' + Time.now.strftime("%Y-%m-%d %H:%M:%S") + '] '
        # This seems gross, fix this with better rubies.
        if m.codepoints.first == 1 && m.match(/ACTION/) 
          message << " * #{nick} #{m.gsub(/^.?ACTION /, '')}"
        else 
          message << "<#{nick}> #{m}"
        end
        return message
      end

      def sync_logfile
        unless @output.path == today_log
          @output.close
          @output = File.open(today_log, 'a')
          @output.sync = true
        end
      end
    end
  end
end
