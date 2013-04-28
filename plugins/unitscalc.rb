class UnitsCalc
  include Cinch::Plugin
  UNITS_PATH = "/usr/bin/units"

  self.help = "Use .math <problem> to do basic math or .convert <thing 1> to <thing 2> to do a unit conversion. (e.g. .convert 5 feet to meters .math 2 + 4)"

  match /convert (.+)/,  method: :convert
  match /math (.+)/,     method: :math

  def initialize(*args)
    super
  end

  def convert(m, conversion_string)
    return unless units_binary_exists?

    nick = m.user.nick
    match = conversion_string.match(/([+\d\.-]+)\s*([\/*\s\w]+) to ([\/*\s\w]+)$/)

    unless match.nil?
      num = match[1]
      units_from = match[2]
      units_to = match[3]

      units_output = IO.popen([UNITS_PATH, "-t", "#{num} #{units_from}", units_to])

      # we only take one line here because the first line of output is
      # either an error message or the part of the conversion output we
      # want.
      units_line = units_output.readline
      units_line.chomp!

      if units_line =~ /Unknown unit/
        m.reply "Sorry, #{units_line.downcase}.", true
      elsif units_line =~ /conformability error/
        m.reply "Sorry, there was a conformability error when making that conversion.", true
      else
        m.reply "#{num} #{units_from} is #{units_line} #{units_to}.", true
      end
    else
      m.reply "Sorry, that didn't match the regexp.", true
    end
  end

  def math(m, problem_string)
    return unless units_binary_exists?

    units_output = IO.popen([UNITS_PATH, "-t", problem_string])
    units_line = units_output.readline
    units_line.chomp!

    m.reply "#{units_line}", true
  end

  def units_binary_exists?
    return true if File.exist? UNITS_PATH
    debug "Cinch can't find the unit conversion binary."
    false
  end
end
