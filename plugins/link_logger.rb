# -*- coding: utf-8 -*-
class LinkLogger
  include Cinch::Plugin
  require 'nokogiri'
  require 'open-uri'

  listen_to :channel
  self.help = 'Use .links to see the last 10 links users have posted to the channel.'
  match /links/

  def initialize(*args)
    super
    @storage = Storage.new('yaml/links.yaml') 
    @storage.data[:history] ||= Hash.new
  end

  def execute(m)
    top10 = @storage.data[:history][m.channel.name].values.sort {|a,b| b[:time] <=> a[:time] }
    m.user.send "Recent Links in #{m.channel}"
    top10[0,10].each_with_index do |link, i|
      if link[:title].nil? 
        m.user.send "#{i + 1}. #{expand(link[:short_url])}"
      else 
        m.user.send "#{i + 1}. #{link[:short_url]} ∴ #{link[:title]}"  
      end
    end
  end

  def listen(m)
    urls = URI.extract(m.message, ["http", "https"])
    urls.each do |url|
      @storage.data[:history][m.channel.name] ||= Hash.new 
  
      if @storage.data[:history][m.channel.name].key?(url)
        link = @storage.data[:history][m.channel.name][url]
        m.reply("#{link[:short_url]} ∴  #{link[:title]}") unless link[:title].nil?
        if link[:count] == 1
          m.reply "That was already linked by #{link[:nick]} #{link[:time].ago_in_words}.", true 
        else 
          m.reply "That was already linked #{link[:count]} times. " + 
                  "#{link[:nick]} was the first to link it #{link[:time].ago_in_words}.", true
        end
        @storage.data[:history][m.channel.name][url][:count] += 1
      # Twitter Statuses
      elsif tweet = url.match(/https?:\/\/mobible|w{3}?\.?twitter\.com\/?#?!?\/([^\/]+)\/statuse?s?\/(\d+)\/?/)
        debug 'TWEEEEET'
        page = Nokogiri::HTML(open("http://mobile.twitter.com/#{tweet[1]}/status/#{tweet[2]}")).css('.status')
        status = page.first.content.strip
        m.reply "@#{tweet[1]}: #{status}"
      else   
        short_url = shorten(url)
        title = get_title(url)
        
        # Only spam the channel if you have a title and url.
        m.reply("#{short_url} ∴  #{title}") if short_url && title 

        @storage.data[:history][m.channel.name][url] = {:nick => m.user.nick, 
                                                        :title => title || nil, 
                                                        :count => 1,
                                                        :short_url => short_url,
                                                        :time => Time.now }
      end
    end

    if urls 
      synchronize(:save_links) do 
        @storage.save   
      end
    end
  end

  private

  


  def get_title(url)
    # Make sure the URL is legit
    url = URI::extract(url, ["http", "https"]).first

    # If the link is to an image, extract the filename.
    if url.match(/\.jpg|gif|png$/)
      # unless it's from reddit, then change the url to the gallery to get the image's caption.
      if url.match(/^http:\/\/i\.imgur\.com/)
        url = "http://imgur.com/#{url.match(/([A-Za-z0-9]{5})\.jpg|gif|png$/)[1]}"
      else 
        return "Image: #{url.match(/\/([^\/]+\.jpg|gif|png)$/)[1]}"
      end
    end

    debug url 

    
    # Grab the element, return nothing if  the site doesn't have a title.
    page = Nokogiri::HTML(open(url)).css('title')
    return page.first.content.strip.gsub(/\s+/, ' ') unless page.empty?
  end
end
