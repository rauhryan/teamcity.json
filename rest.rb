require 'rubygems'
require 'json'
require 'net/http'
require 'active_support'
require 'crack'

URL = "http://teamcity.codebetter.com/guestAuth/app/rest/"

xml = Net::HTTP.get_response(URI.parse("#{URL}projects")).body

puts Crack::XML.parse(xml).to_json

