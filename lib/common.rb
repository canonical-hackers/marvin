require 'ruby-bitly'

def shorten(url)
  @bitlyconfig = YAML::load(File.open('config/bitly.yml'))
  return Bitly.shorten(url, @bitlyconfig['username'], @bitlyconfig['apikey']).url
end

def truncate(text, length = 250) 
  if text.length > length 
    text = text[0,length - 1] + '...'
  end
  return text
end

