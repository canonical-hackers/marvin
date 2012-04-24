class Dice
  require 'time-lord'
  include Cinch::Plugin

  class Score < Struct.new(:nick, :score, :time)
  end

  $commands['roll'] = "Roll a random assortment of dice with .roll, you can also use .roll (dice count)d(sides) to roll specific dice (e.g. '.roll 4d6 3d20')"

  match /roll$/, method: :roll_bag 
  match /roll (.*)/, method: :roll

  def initialize(*args)
    super
    @scores = {}
  end

  def roll_bag(m) 
    nick = m.user.nick.downcase
    bag = "#{rand(30)}d6 #{rand(25)}d10 #{rand(20)}d20" 
    result = roll_dice(bag) 
    m.reply "#{nick} rolls a huge bag of dice totalling #{result[:total]}."
    if @scores.key?(nick)
      if @scores[nick].score < result[:total]
        m.reply "This is a new high score, their old score was #{@scores[nick].score}, #{@scores[nick].time.ago_in_words}"
        @scores[m.user.nick.downcase] = Score.new(m.user.nick, result[:total], Time.now)
      end
    else 
      @scores[m.user.nick.downcase] = Score.new(m.user.nick, result[:total], Time.now)
    end  
  end

  def roll(m, bag) 
    result = roll_dice(bag) 
    response = "#{result[:rolls].join(', ')} totalling #{result[:total]}"
    m.reply "#{m.user.nick} rolls #{response}" unless response.nil?
  end

  private 

  def roll_dice(dice)
    rolls = []
    total = 0 
    dice = dice.split(' ')
    dice.each do |die| 
      if die.match(/\d+d\d+/)
        count = die.match(/(\d+)d\d+/)[1].to_i rescue 0
        sides = die.match(/\d+d(\d+)/)[1].to_i rescue 0 
      elsif die.match(/d\d+/) 
        count = 1
        sides = die.match(/d(\d+)/)[1].to_i rescue 0
      end
      unless count.nil? || sides.nil? 
        roll = roll_dice_type(sides, count)
        unless roll.nil?
          rolls << roll[:text]
          total += roll[:total] 
        end
      end
    end
    return { :rolls => rolls, :total => total }
  end

  def roll_dice_type(sides, count) 
    unless sides < 1 || count < 1 
      rolls = []
      count.times { rolls << rand(sides) + 1 } 
      
      return {:total => rolls.inject(:+), 
              :text => "#{count}d#{sides} [#{rolls.join(',')}]" }  
    end 
  end
end
