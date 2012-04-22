# -*- coding: utf-8 -*-
class TitleLookup
  include Cinch::Plugin
  require 'nokogiri'
  require 'open-uri'
  require 'ruby-bitly'

  listen_to :channel

  def listen(m)
    urls = URI.extract(m.message, ["http", "https"])
    urls.each do |url|
      short_url = Bitly.shorten(url, @@bitlyconfig['username'], @@bitlyconfig['apikey']).url
      m.reply("#{short_url} ∴  #{ get_title(url) || 'Untitled'}" )
    end
  end

  private

  def get_title(url)
    # Make sure the URL is legit
    url = URI::extract(url, ["http", "https"]).first

    # Grab the element
    return Nokogiri::HTML(open(url)).css('title').first.content
  end
end
