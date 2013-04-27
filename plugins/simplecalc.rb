class SimpleCalc
  require 'calc'
  include Cinch::Plugin
  cooldown

  self.help = "Use .math <problem> to do simple math. (i.e. .math 2 + 2)"

  match /math (.+)/

  def execute(m, problem)
    begin
      answer = Calc.evaluate(problem)

      unless answer == problem
        m.reply "#{Calc.evaluate(problem)}", true
      end
    rescue ZeroDivisionError
      m.reply "Fuck you.", true
    end
  end
end

