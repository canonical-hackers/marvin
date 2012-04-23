require 'ruby-bitly'

def shorten(url)
  @bitlyconfig = YAML::load(File.open('config/bitly.yml'))
  return Bitly.shorten(url, @bitlyconfig['username'], @bitlyconfig['apikey']).url
end

