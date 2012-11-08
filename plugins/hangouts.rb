# -*- coding: utf-8 -*-
class Hangouts
  include Cinch::Plugin
  require 'time-lord'

  self.help = "Use .hangouts to see the info for any recent hangouts."
  
  match /hangouts/
  
  def initialize(*args)
    super
    @storage = Storage.new('yaml/hangouts.yml')
    @storage.data[:hangouts] ||= {}
    @expire_mins = 120
  end

  def execute(m)
    hangouts = sort_and_expire
    if hangouts.empty?
      m.user.notice "No hangouts have been linked recently!"
    else 
      m.user.notice "These hangouts have been linked in the last #{@expire_mins} minutes. They may or may not still be going."
      hangouts.each do |hangout| 
        m.user.notice "#{hangout[:user]} started a hangout #{hangout[:time].ago_in_words} ago at #{hangout_url(hangout[:id])}"
      end
    end
  end

  listen_to :channel
  def listen(m)
    # https://plus.google.com/hangouts/_/fbae432b70a47bdf7786e53a16f364895c09d9f8
    if m.message.match(/plus.google.com\/hangouts\//)
      hangout_id = m.message[/[^\/?]{40}/, 0]
      unless hangout_id.nil? || @storage.data[:hangouts].key?(hangout_id)
        @storage.data[:hangouts][hangout_id] = {:user => m.user.nick, :time => Time.now} 
        synchronize(:hangout_save) do
          @storage.save
        end
      end
    end
  end

  def sort_and_expire   
    hangouts = @storage.data[:hangouts].each_pair.map { |x,y| y[:id] = x;y }
    hangouts.delete_if { |h| Time.now - h[:time] > @expire_mins * 60 } 
    hangouts.sort! { |x,y| y[:time] <=> x[:time] } 
    return hangouts 
  end

  def hangout_url(id)
    return shorten("https://plus.google.com/hangouts/_/#{id}")
  end
end
