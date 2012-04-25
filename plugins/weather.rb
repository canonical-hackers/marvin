# -*- coding: utf-8 -*-
class Weather
  require 'weather-underground'
  require 'time-lord'
  include Cinch::Plugin

  cooldown

  match /weather (.*)/
  match /w (.*)/

  def initialize(*args)
    super
    @weather = WeatherUnderground::Base.new()
  end

  def get_weather(query)
    weather_data = @weather.CurrentObservations(query)

    unless weather_data.temp_f == ""
      location = weather_data.display_location[0].full
      temp_f = weather_data.temp_f
      conditions = weather_data.weather.downcase
      last_updated = weather_data.observation_time.gsub(/Last Updated on/, "")
      last_updated_ago = Time.parse(last_updated).ago_in_words

      message = "In #{location} it is #{conditions} "
      message << "and #{temp_f}°F "
      message << "(last updated about #{last_updated_ago})"

      return message
    else
      return "Sorry, couldn't find #{query}."
    end
  end

  def execute(m, query)
    m.reply(get_weather(query))
  end
end
