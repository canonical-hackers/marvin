# -*- coding: utf-8 -*-
class LinkLogger
  include Cinch::Plugin
  require 'twitter'
  require 'nokogiri'
  require 'open-uri'
  require 'tumblr'

  listen_to :channel
  self.help = 'Use .links to see the last 10 links users have posted to the channel.'
  match /links/

  def initialize(*args)
    super
    @storage = Storage.new('yaml/links.yaml')
    @storage.data[:history] ||= Hash.new
  end

  def execute(m)
    if m.channel.nil?
      m.user.msg "You must use that command in the main channel."
      return
    end

    if config[:tumblr]
      msg = "Links are available @ http://#{config[:tumblr][:group]}"
      msg << " Password: #{config[:tumblr][:tpass]}" if config[:tumblr][:tpass]
      m.user.send msg
    else
      m.user.send "Recent Links in #{m.channel}"
      last = @storage.data[:history][m.channel.name].values.sort {|a,b| b[:time] <=> a[:time] }
      last[0,10].each_with_index do |link, i|
        if link[:title].nil?
          m.user.send "#{i + 1}. #{expand(link[:short_url])}"
        else
          m.user.send "#{i + 1}. #{link[:short_url]} ∴ #{link[:title]}"
        end
      end
    end
  end

  def listen(m)
    urls = URI.extract(m.message, ["http", "https"])
    urls.each do |url|
      @storage.data[:history][m.channel.name] ||= Hash.new

      if @storage.data[:history][m.channel.name].key?(url)
        link = @storage.data[:history][m.channel.name][url]

        if spam_channel?(url)
          m.reply("#{link[:short_url]} ∴  #{link[:title]}") unless link[:title].nil?

          unless config[:reportstats] == false || link[:nick] == m.user.nick
            if link[:count] == 1
              m.reply "That was already linked by #{link[:nick]} #{link[:time].ago_in_words}.", true
            else
              m.reply "That was already linked #{link[:count]} times. " +
                      "#{link[:nick]} was the first to link it #{link[:time].ago_in_words}.", true
            end
          end
        end
        @storage.data[:history][m.channel.name][url][:count] += 1
      # Twitter Statuses
      elsif url.match(/^https?:\/\/mobile|w{3}?\.?twitter\.com/)
        twitter = {}
        if tweet = url.match(/https?:\/\/mobile|w{3}?\.?twitter\.com\/?#?!?\/([^\/]+)\/statuse?s?\/(\d+)\/?/)
          unless config[:twitter] == false
            twitter[:status] = Twitter.status(tweet[2]).text
            twitter[:status].gsub!(/[\n]+/, "");
            twitter[:user] = tweet[1]
            m.reply "@#{twitter[:user]} tweeted \"#{twitter[:status]}\"."
            post_quote(twitter[:status], "<a href='#{url}'>#{twitter[:user]} on Twitter</a>")
          end
        elsif tweet = url.match(/https?:\/\/mobile|w{3}?\.?twitter\.com\/?#?!?\/([^\/]+)/)
          if spam_channel?(url)
            m.reply "http://twitter.com/#{tweet[1]} ∴ #{tweet[1]} on Twitter"
          end
        end

      else
        short_url = shorten(url)
        title = get_title(url)

        tumble(url, title, m.user.nick) if config[:tumblr]

        # Only spam the channel if you have a title and url.
        if spam_channel?(url)
          m.reply("#{short_url} ∴  #{title}") if short_url && title
        end

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

  def tumble(url, title, nick)
    return unless config[:tumblr]

    # Redit
    if redit = url.match(/^https?:\/\/.*imgur\.com.*([A-Za-z0-9]{5}\.\S{3})/)
      post_image("http://i.imgur.com/#{redit[1]}", title, nick)
    # Images
    elsif url.match(/\.jpg|jpeg|gif|png$/i)
      post_image(url, title, nick)
    # Youtube / Vimeo
    elsif url.match(/https?:\/\/[^\/]*\.?(youtube|youtu|vimeo)\./)
      post_video(url, nil, nick)
    # Everything else
    else
      post_link(url, title, nick)
    end
  end

  def post_link(url, title = nil, nick = nil)
    document = tumblr_header('link', {'name' => title, 'tags' => nick})
    document << url
    tublr_post(document)
  end

  def post_quote(quote, source, nick = nil)
    document = tumblr_header('quote', {'source' => source, 'tags' => nick})
    document << quote
    tublr_post(document)
  end

  def post_image(url, title = nil, nick = nil)
    document = tumblr_header('text', {'title' => title, 'tags' => nick})
    document << "<p><a href='#{url}'><img src='#{url}' style='max-width: 650px;'/></a><br/><a href='#{url}'>#{url}</a></p>"
    tublr_post(document)
  end

  def post_video(url, title, nick = nil)
    document = tumblr_header('video', {'caption' => title, 'tags' => nick})
    document << url
    tublr_post(document)
  end

  def tumblr_header(type = 'text', options = {})
    opts = {'type' => type, 'hostname' => config[:tumblr][:hostname]}.update(options)
    doc = YAML::dump(opts)
    doc << "---\n"
    return doc
  end

  def tublr_post(doc)
    post = Tumblr::Post.load(doc)
    client = Tumblr::Client.new(config[:tumblr][:hostname], YAML.load(File.open('config/tumblr_creds')))
    request = post.post(client)

    request.perform do |response|
      if response.success?
        debug "Success"
      else
        debug "Something went wrong  #{response.code} #{response.message}"
      end
    end
  end

  def spam_channel?(url)
    whitelisted?(url) && !logonly?
  end

  def whitelisted?(url)
    return true unless config[:whitelist]

    debug "Checking Whitelist! #{config[:whitelist]} url: #{url}"
    return true if url.match(Regexp.new("https?\/\/.*\.?#{config[:whitelist].join('|')}\."))

    return false
  end

  def get_title(url)
    # Make sure the URL is legit
    url = URI::extract(url, ["http", "https"]).first

    # If the link is to an image, extract the filename.
    if url.match(/\.jpg|jpeg|gif|png$/)

      # unless it's from reddit, then change the url to the gallery to get the image's caption.
      if url.match(/https?:\/\/i\.imgur\.com.+([A-Za-z0-9]{5})\.(jpg|jpeg|png|gif)/)
        imgur_id = url.match(/https?:\/\/i\.imgur\.com.+([A-Za-z0-9]{5})\.(jpg|jpeg|png|gif)/)[1]
        url = "http://imgur.com/#{imgur_id}"
      else
        site = url.match(/\.([^\.]+\.[^\/]+)/)
        return site.nil? ? "Image [#{url}]!!!" : "Image from #{site[1]}"
      end
    end

    # Grab the element, return nothing if  the site doesn't have a title.
    page = Nokogiri::HTML(open(url)).css('title')
    return page.first.content.strip.gsub(/\s+/, ' ') unless page.empty?
  end


  def logonly?
    return false if config[:logonly].nil?
    return true  if config[:logonly] == true
    false
  end

end
