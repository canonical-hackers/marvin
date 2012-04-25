# -*- coding: utf-8 -*-
class LinkLogger
  class Link < Struct.new(:link, :nick, :title, :short_url, :time)
    def to_s 
      "#{short_url} ∴ #{title} (#{time.ago_in_words})"
    end 
  end

  include Cinch::Plugin
  require 'nokogiri'
  require 'open-uri'

  listen_to :channel
  self.help = 'Use .links to see the last 10 links users have posted to the channel.'
  match /links/

  def initialize(*args)
    super
    @history = Hash.new(0)
  end

  def execute(m)
    m.user.send "Recent Links in #{m.channel}"
    top10 = @history.values.sort {|a,b| b[:time] <=> a[:time] }
    top10[0,10].each_with_index { |link, i| m.user.send "#{i + 1}. #{link}" }  
  end

  def listen(m)
    urls = URI.extract(m.message, ["http", "https"])
    urls.each do |url|
      if @history.key?(url)
        m.reply("#{@history[url].short_url} ∴  #{@history[url].title}")
        m.reply "That was already linked by #{@history[url].nick} #{@history[url].time.ago_in_words}.", true
      else   
        short_url = shorten(url)
        title = get_title(url).gsub(/\n/, '') || 'Untitled'
        m.reply("#{short_url} ∴  #{title}")
        @history[url] = Link.new(url, m.user.nick, title, short_url, Time.now)
      end
    end
  end

  private

  def get_title(url)
    # Make sure the URL is legit
    url = URI::extract(url, ["http", "https"]).first

    # Grab the element
    return Nokogiri::HTML(open(url)).css('title').first.content.strip.gsub(/\s+/, ' ')
  end
end
