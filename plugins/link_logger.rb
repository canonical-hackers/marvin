# -*- coding: utf-8 -*-
class LinkLogger
  class Link < Struct.new(:link, :nick, :title, :short_url, :time)
    def to_s 
      "#{short_url} - #{title.gsub(/\n/, '')}"
    end 
  end

  include Cinch::Plugin
  require 'nokogiri'
  require 'open-uri'

  listen_to :channel
  match /links/

  def initialize(*args)
    super
    @history = Hash.new(0)
  end

  def execute(m)
    m.user.send "Recent Links in #{m.channel}", true
    top10 = @history.values.sort {|a,b| a[:time] <=> b[:time] }
    top10.each_with_index { |link, i| m.channel.send "#{i + 1}. #{link}", true }  
  end

  def listen(m)
    urls = URI.extract(m.message, ["http", "https"])
    urls.each do |url|
      short_url = shorten(url)
      title = get_title(url).gsub(/\n/, '') || 'Untitled'
      m.reply("#{short_url} ∴  #{title}")
      unless @history.key?(url)
        @history[url] = Link.new(url, m.user.nick, title, short_url, Time.now)
      end
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
