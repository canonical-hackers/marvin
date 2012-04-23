class Dice
  include Cinch::Plugin
  $commands['roll'] = "Use !roll (dice count)d(sides) to roll dice. You can roll multiple dice types at once '!roll 2d6 3d20' if you need"

  match /roll (.*)/

  def execute(m, roll) 
    rolls = []
    total = 0 

    dice = roll.split(' ')
    dice.each do |die| 
      if die.match(/\d+d\d+/)
        count = die.match(/(\d+)d\d+/)[1].to_i rescue 0
        sides = die.match(/\d+d(\d+)/)[1].to_i rescue 0 
      elsif die.match(/d\d+/) 
        count = 1
        sides = die.match(/d(\d+)/)[1].to_i rescue 0
      end
      unless count.nil? || sides.nil? 
        roll = roll(sides, count)
        unless roll.nil?
          rolls << roll[:text]
          total += roll[:total] 
        end
      end
    end

    unless rolls.blank? 
      m.reply "#{m.user.nick} rolls #{rolls.join(',')} totalling #{total}"
    end
  end

  private 

  def roll(sides, count) 
    unless sides < 1 || count < 1 
      rolls = []
      count.times { rolls << rand(sides) + 1 } 
      
      return { :total => rolls.sum, :text => "#{count}d#{sides} [#{rolls.join(', ')}]" }  
    end 
  end
end
