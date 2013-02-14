# -*- coding: utf-8 -*-
class UrbanDictionary
  include Cinch::Plugin

  cooldown
  self.help = "Use .ud <term> to see the Urban Dictionary definition for that term."
  match /ud (.*)/

  def execute(m, term)
    m.reply( "Urban Dictionary ∴ #{term}: #{get_def(term)} [#{shorten("http://www.urbandictionary.com/define.php?term=#{term}")}]")
  end

  private

  def get_def(term)
    # URI Encode
    term = URI.escape(term, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))

    url = "http://www.urbandictionary.com/define.php?term=#{term}"

    # Grab the element
    text = get_html_element(url, '.definition')

    #Make sure it's not terribly long
    return truncate(text, 250)
  end
end

