# -*- coding: utf-8 -*-
class UrbanDictionary
  include Cinch::Plugin
  require 'nokogiri'
  require 'open-uri'

  match /ud (.*)/

  def execute(m, term)
    m.reply( "Urban Dictionary ∴ #{term}: #{get_def(term) || 'Definition not found'}")
  end

  private

  def get_def(term)
    # URI Encode
    term = URI.escape(term, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))

    url = "http://www.urbandictionary.com/define.php?term=#{term}"

    # Make sure the URL is legit
    url = URI::extract(url, ["http", "https"]).first

    # Grab the element
    return Nokogiri::HTML(open(url)).css('.definition').first.content
  end
end

