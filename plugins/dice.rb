class Dice
  include Cinch::Plugin

  match /roll (.*)/

  def execute(m, roll) 
    rolls = []

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
        rolls << roll unless roll.nil?
      end
    end

    unless rolls.blank? 
      m.reply "#{m.user.nick} rolls #{rolls.join(', ')}"
    end
  end

  private 

  def roll(sides, count) 
    unless sides < 1 || count < 1 
      rolls = []
      count.times { rolls << rand(sides) + 1 } 
      return "#{count}d#{sides} [#{rolls.join(', ')}]" 
    end 
  end
end
