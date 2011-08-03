require 'rubygems'
require 'sinatra'
require 'json'
require 'net/http'
require 'crack'
require 'nokogiri'

#DOMAIN = "teamcity.codebetter.com"
DOMAIN = "teamcity"
PORT = 8082
URL = "#{DOMAIN}/guestAuth/app/rest/"

get '/projects' do 
	content_type :json

	http = Net::HTTP.new(DOMAIN,PORT)
	resp, data = http.get("/guestAuth/app/rest/projects", {'Accept', "application/json"})
	data
end

get "/projects/:id" do |id|
	content_type :json

	http = Net::HTTP.new(DOMAIN,PORT)
	resp, data = http.get("/guestAuth/app/rest/projects/id:#{id}/buildTypes", {'Accept', "application/json"})

	buildTypes = Crack::JSON.parse(data)

	buildTypes["buildType"].each do |build|

		response, json = http.get("/guestAuth/app/rest/builds/?locator=buildType:#{build["id"]},count:5", {'Accept', "application/json"})

		build["history"] = Crack::JSON.parse(json)["build"]
	end

	buildTypes.to_json
end

get '/builds/all' do 
	content_type :json

	http = Net::HTTP.new(DOMAIN, PORT)
	resp, data = http.get("/guestAuth/app/rest/projects", {'Accept', "application/json"})

	projects = Crack::JSON.parse(data);

	projects["project"].each do |project|

		project["builds"] = []
		resp, data = http.get("/guestAuth/app/rest/projects/id:#{project["id"]}/buildTypes", {'Accept', "application/json"})

		buildTypes = Crack::JSON.parse(data)

		buildTypes["buildType"].each do |build|

			response, json = http.get("/guestAuth/app/rest/builds/?locator=buildType:#{build["id"]},count:5", {'Accept', "application/json"})

			build["history"] = Crack::JSON.parse(json)["build"]
			project["builds"] << build
		end
	end

	projects.to_json
end


get '/' do 
	erb :index
end

def api(route, &block)
	http = Net::HTTP.new(DOMAIN)
	resp, data = http.get(route, {'Accept', "application/json"})
	block.call data
end

