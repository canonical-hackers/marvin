class TitleLookup
  include Cinch::Plugin
  require 'nokogiri'
  require 'open-uri'

  listen_to :channel

  def listen(m)
    urls = URI.extract(m.message, ["http", "https"])
    urls.each do |url| 
      m.reply( "SHORTURL .:.  #{ get_title(url) || 'Untitled'}" )
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
