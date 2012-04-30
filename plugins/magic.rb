# -*- coding: utf-8 -*-
class Magic
  include Cinch::Plugin

  cooldown
  self.help = "Use .mtg <card name> to see the info for that card."

  match /mtg (.*)/

  def execute(m, term)
    term = get_card(term)
    m.reply term || 'Card not found', term.nil?
  end

  private

  def get_card(term)
    # URI Encode
    term = URI.escape('!' + term, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    url = "http://magiccards.info/query?q=#{term}"

    # Make sure the URL is legit
    url = URI::extract(url, ["http", "https"]).first

    # Grab the text
    begin 
      data = get_html_element(url, '//table[3]/tr/td[2]', 'xpath').to_html

      name = data.match(/<span.*>\n<a href=[^>]*>([^<]+)<\/a>/)[1] rescue 'NO MATCH'
      link = "http://magiccards.info" + data.match(/<span.*>\n<a href="([^>]*)">[^<]+<\/a>/)[1] rescue 'NO MATCH'
      info = data.match(/<p[^>]*>([^<]+)<\/p>/)[1].gsub(/\n/, '').gsub(/—/, '·').gsub(/\s\(\d*\)/, '')  rescue 'NO MATCH'
      text = data.match(/<p class="ctext"><b[^>]*>(.+)<\/b><\/p>/)[1].gsub(/<br><br>/, ' ') rescue 'NO MATCH'

      card = "#{name} [#{info}] - #{text}"

      # Truncate if it's super long
      card = truncate(card, 300) 

      return "#{card} [#{link}]"
    rescue 
    end 
  end
end

