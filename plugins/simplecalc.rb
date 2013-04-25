class SimpleCalc
  require 'calc'

  include Cinch::Plugin

  self.help = "Use .math <problem> to do simple math. (i.e. .math 2 + 2)"

  match /math (.+)/

  def execute(m, problem)
    begin
      m.reply "#{Calc.evaluate(problem)}", true
    rescue ZeroDivisionError
      m.reply "Fuck you.", true
    end
  end
end

