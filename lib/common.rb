require 'ruby-bitly'

def shorten(url)
  # Let's not shorten urls that don't really need it

  # Use the youtube shortener matcher if it's for YT
  if yt_id = url.match(/http:\/\/w{3}?\.?youtube\.com.+(\S{11})/) 
    return "http://youtu.be/#{yt_id[1]}"
  # Short Enough
  elsif url.length < 25
    return url
  # Already Shortened
  elsif url.match(/^http:\/\/bit\.ly/) || 
        url.match(/^http:\/\/tinyurl\.com/) || 
        url.match(/^http:\/\/t\.co/) || 
        url.match(/^http:\/\/goo\.gl/) 
    return url     
  else
    @bitlyconfig = YAML::load(File.open('config/bitly.yml'))
    return Bitly.shorten(url, @bitlyconfig['username'], @bitlyconfig['apikey']).url
  end
end

def truncate(text, length = 250) 
  if text.length > length 
    text = text[0,length - 1] + '...'
  end
  return text
end

