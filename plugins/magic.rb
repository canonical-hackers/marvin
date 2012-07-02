# -*- coding: utf-8 -*-
class Magic
  include Cinch::Plugin

  cooldown
  self.help = "Use .mtg <card name> to see the info for that card."

  match /mtg (.*)/
  match /magic (.*)/

  def execute(m, term)
    m.reply get_card(term)
  end

  def get_card(term)
    # Fetch the html for the search term
    data = get_card_data(term)
    
    if data.nil? 
      return '[Magic] Card not found!'
    else 
      # Build card string
      card = "#{get_card_name(data)} [#{get_card_info(data)}] - #{get_card_text(data)}"

      # Truncate if it's super long
      card = truncate(card, 300) 

      return "[Magic] #{card} [#{get_card_link(data)}]"
    end 
  end

  def get_card_info(data)
    begin 
      text = data.match(/<p[^>]*>([^<]+)<\/p>/)[1]
      # Replace Newlines, unicode lines, total mana, and large spaces.  
      text = text.gsub(/\n/, '')
      text = text.gsub(/—/, '·')
      text = text.gsub(/\s\(\d*\)/, '')
      text = text.gsub(/\s{2,}/, ' ')

      # Remove pesky whitespace that might have snuck in...
      text.strip!

      return text
    rescue
      return 'Error getting this card\'s info.'
    end
  end

  def get_card_name(data)
    begin
      return data.match(/<a href=[^>]*>([^<]+)<\/a>/)[1] 
    rescue
      'Error finding this card\'s name'
    end
  end

  def get_card_link(data) 
    begin 
      return "http://magiccards.info" + data.match(/<a href="([^>]*)">[^<]+<\/a>/)[1]
    rescue 
      'Error finding this card\'s url'
    end
  end

  def get_card_text(data)
    begin 
      return data.match(/<p class="ctext"><b[^>]*>(.+)<\/b><\/p>/)[1].gsub(/<br><br>/, ' ')
    rescue 
      'Error finding this card\'s description.'
    end
  end

  def get_card_data(term)
    # URI Encode the term and build the URL
    term = URI.escape('!' + term, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    url = "http://magiccards.info/query?q=#{term}"

    # Make sure the URL is legit
    url = URI::extract(url, ["http", "https"]).first

    # Grab the html block because magiccards.info fucking loves tables 
    # and hates helpful ids and classnames
    begin 
      return get_html_element(url, '//table[3]/tr/td[2]', 'xpath').to_html
    rescue 
      debug "Error looking up card: #{term}"
      return nil
    end
  end
end

