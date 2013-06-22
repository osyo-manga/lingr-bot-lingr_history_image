# -*- encoding: UTF-8 -*-
require 'sinatra'
require 'json'
require "mechanize"

load "gyazo.rb"


get '/' do
	"Hello, world"
end


get '/lingr_history_image' do
	"lingr_history_image"
end


get '/phantomjs' do
	`phantomjs --version`
end


def lingr_history_url? (url)
	return /^http:\/\/lingr.com\/room\/vim\/archives\/\d{4}\/\d{2}\/\d{2}#message-\d+$/ =~ url
end


post '/lingr_bot' do
	content_type :text
	json = JSON.parse(request.body.string)
	json["events"].select {|e| e['message'] }.map {|e|
		text = e["message"]["text"]
		name = e["message"]["nickname"]

		if lingr_history_url? text
			url = text
			file = "./temp/lingr_#{Time.now.to_i}.png"
			`phantomjs lingr_history_image.js #{url} #{file}`
			result = gyazo.upload file
			return result
		end
	}
	return ""
end


