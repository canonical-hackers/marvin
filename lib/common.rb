# -*- coding: utf-8 -*-

module Common
  require 'ruby-bitly'
  require 'nokogiri'
  require 'open-uri'


  def get_html_element(url, selector, mode = 'css')
    # Make sure the URL is legit
    url = URI::extract(url, ["http", "https"]).first

    data = case mode
      when 'css'   then Nokogiri::HTML(open(url)).css(selector).first.content
      when 'xpath' then Nokogiri::HTML(open(url)).xpath(selector).first
    end

    return data
  end

  def expand(url)
    if url.match(/bit\.ly/)
      return Bitly.expand(url, shared[:bitly][:username], shared[:bitly][:apikey]).long_url
    else
      return url
    end
  end

  def shorten(url)
    # Use the youtube shortener matcher if it's for YT
    if yt_id = url.match(/http:\/\/w{3}?\.?youtube\.com.+(\S{11})/)
      return "http://youtu.be/#{yt_id[1]}"
          # Short Enough
    elsif url.length < 45 ||
          # Already Shortened
          url.match(/^http:\/\/bit\.ly/) ||
          url.match(/^http:\/\/tinyurl\.com/) ||
          url.match(/^http:\/\/t\.co/) ||
          url.match(/^http:\/\/goo\.gl/)
      return url
    end
    return Bitly.shorten(url, shared[:bitly][:username], shared[:bitly][:apikey]).url
  end

  def truncate(text, length = 250)
    text = text.gsub(/\n/, ' · ')
    if text.length > length
      text = text[0,length - 1] + '...'
    end
    return text
  end

  def time_format(secs)
    data = time_parse(secs)
    string = ''

    string << "#{data[:days]}d "  unless data[:days].zero?  && string == ''
    string << "#{data[:hours]}h " unless data[:hours].zero? && string == ''
    string << "#{data[:mins]}m "  unless data[:mins].zero?  && string == ''
    string << "#{data[:secs]}s"

    return string
  end

  def time_parse(secs)
    days = secs / 86400
    hours = (secs % 86400) / 3600
    mins = (secs % 3600) / 60
    secs = secs % 60

    return { :days => days.floor,
             :hours => hours.floor,
             :mins => mins.floor,
             :secs => secs.floor }
  end
end
