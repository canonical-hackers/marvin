# -*- coding: utf-8 -*-
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
  @bitlyconfig = YAML::load(File.open('config/bitly.yml'))
  if url.match(/bit\.ly/) 
    return Bitly.expand(url, @bitlyconfig['username'], @bitlyconfig['apikey']).long_url
  else 
    return url 
  end
end

def shorten(url)
  # Let's not shorten urls that don't really need it

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
  
  @bitlyconfig = YAML::load(File.open('config/bitly.yml'))
  return Bitly.shorten(url, @bitlyconfig['username'], @bitlyconfig['apikey']).url
end

def truncate(text, length = 250) 
  text = text.gsub(/\n/, ' · ')
  if text.length > length 
    text = text[0,length - 1] + '...'
  end
  return text
end

