require 'http'
require 'json'
require_relative 'weather'


intro_msg = "---------------------------\n| MartTec: My Weather App |\n---------------------------"
puts intro_msg
ask_user_city = "Please enter your city: "
puts ask_user_city
user_city = gets.chomp.capitalize
confirmation_msg = "Got it! Checking the current weather in #{user_city}..."
puts confirmation_msg
launch_weather = Weather.new(user_city)
launch_weather.get_location
puts "What weather report would you like?\n1) Current\n2) Daily\n3) Alerts"
user_selection = gets.chomp.capitalize
puts launch_weather.get_weather(user_selection)
