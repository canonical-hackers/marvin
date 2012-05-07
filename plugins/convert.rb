class Convert
  include Cinch::Plugin
  listen_to :channel
  self.help = "Use .convert <thing 1> to <thing 2> to do a unit conversion. Example: .convert 5 feet to meters"

  match /convert (.+)/

  def initialize(*args)
    super
  end

  def execute(m, conversion_string)
    nick = m.user.nick
    output = String.new
    match = conversion_string.match(/([+\d\.-]+)\s*([\/*\s\w]+) to ([\/*\s\w]+)$/)
    unless match.nil?
      num = match[1]
      units_from = match[2]
      units_to = match[3]

      unless File.exist? "/usr/bin/units"
        m.reply "#{nick}: Sorry, I'm configured to do unit conversion, but I can't find the unit conversion binary."
        return
      end

      units_output = IO.popen(["/usr/bin/units", "-t", "#{num} #{units_from}", units_to])

      # we only take one line here because the first line of output is
      # either an error message or the part of the conversion output we
      # want.
      units_line = units_output.readline
      units_line.chomp!

      if units_line =~ /Unknown unit/
        m.reply "#{nick}: Sorry, #{units_line.downcase}."
      elsif units_line =~ /conformability error/
        m.reply "#{nick}: Sorry, there was a conformability error when making that conversion."
      else
        m.reply "#{nick}: #{num} #{units_from} is #{units_line} #{units_to}."
      end
    else
      m.reply "#{m.user.nick}: Sorry, that didn't match the regexp."
    end
  end
end
