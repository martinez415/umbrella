require "http"
require "json"

class Weather
  attr_accessor :city, :user_selection;

  def initialize(city)
    @city = city
    @user_location = nil 
    @pirate_weather_api_key = ENV.fetch("PIRATE_WEATHER_KEY")
    @gmaps_api_key = ENV.fetch("GMAP_KEY")
  end

  def get_location
    maps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{@city}&key=#{@gmaps_api_key}"
    maps_response = HTTP.get(maps_url)
    raw_maps_response = maps_response.to_s
    parsed_maps_response = JSON.parse(raw_maps_response)
    maps_results = parsed_maps_response.fetch("results")
    address_results = maps_results.at(0)
    geo_results = address_results.fetch("geometry")
    location = geo_results.fetch("location")
    lat = location.fetch("lat")
    lng = location.fetch("lng") 
    @user_location = "#{lat}, #{lng}"
    return @user_location
  end

  def get_weather(user_selection)

    pirate_weather_url = "https://api.pirateweather.net/forecast/#{@pirate_weather_api_key}/#{@user_location}"
    weather_response = HTTP.get(pirate_weather_url)
    raw_weather_respnse = weather_response.to_s
    parse_weather_results = JSON.parse(raw_weather_respnse)
    get_weather_keys =  parse_weather_results.keys   
    weather = parse_weather_results.fetch("currently")

    case user_selection
    when "Current"
      weather = parse_weather_results.fetch("currently")
      current_summary = weather.fetch("summary")
      precip_probability = weather.fetch("precipProbability")
      temp = weather.fetch("temperature")
      return_msg = "Here is your current weather forecast:\nCurrent Weather: #{current_summary}\nRain Probability: #{precip_probability}%\nCurrent Temperature: #{temp}°F"
      return return_msg
    when "Daily"
      weather = parse_weather_results.fetch("daily")
      header = "----------------------------------------------------------------------\n|   Date  |   Forecast   |  High  |  Low  |   Rain   | Humidity | UV |\n----------------------------------------------------------------------"
      puts header
      days = 0
      weekly_forecast = ""
      while days < 5
        timestamp = weather.fetch("data").at(days).fetch("time")
        time = Time.at(timestamp)
        readable_time = time.strftime('%m-%d-%Y')
        daily_summary = weather.fetch("data").at(days).fetch("summary")
        temp_high = weather.fetch("data").at(days).fetch("temperatureHigh")
        temp_low = weather.fetch("data").at(days).fetch("temperatureLow")
        rain_prob = weather.fetch("data").at(days).fetch("precipProbability")
        humidity = weather.fetch("data").at(days).fetch("humidity")
        uv = weather.fetch("data").at(days).fetch("uvIndex")
        weekly_forecast += "#{readable_time}: #{daily_summary} #{temp_high}°F #{temp_low}°F #{rain_prob}% #{humidity} #{uv}\n"
        days+=1
      end
      return weekly_forecast
    when "Alert"
      weather = parse_weather_results.fetch("alerts")
      if weather != []
        weather_alert_title = weather.fetch("title")
        return weather_alert_title
      else
        return "No weather alerts in your area."
      end
    else
      return "Invalid input. Please select a valid menu option."
    end
  end

end
