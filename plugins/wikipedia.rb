# -*- coding: utf-8 -*-
class Wikipedia
  include Cinch::Plugin
  require 'nokogiri'
  require 'open-uri'
  require 'ruby-bitly'
  $commands['wikipedia'] = "Use !w <term> to see the Wikipedia info for that term."

  match /w (.*)/

  def execute(m, term)
    m.reply( "Wikipedia ∴ #{get_def(term) || 'Definition not found'}")
  end

  private

  def get_def(term)
    # URI Encode
    term = URI.escape(term, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    url = "http://en.wikipedia.org/w/index.php?search=#{term}"

    # Make sure the URL is legit
    url = URI::extract(url, ["http", "https"]).first

    # Grab the text
    text = Nokogiri::HTML(open(url)).css('#mw-content-text p').first.content

    # Truncate if it's super long
    truncate(text, 200) 

    return "#{text} [#{shorten(url)}]"
  end
end

