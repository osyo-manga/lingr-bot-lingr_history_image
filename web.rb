# -*- encoding: UTF-8 -*-
require 'sinatra'
require 'json'
require "mechanize"
require 'set'
require 'digest/sha1'
require 'erb'
require 'open-uri'

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
	return /^http:\/\/lingr.com\/room\/.+\/archives\/\d{4}\/\d{2}\/\d{2}#message-\d+$/ =~ url
end

def post_lingr(text, room)
	Thread.start do
		url = text
		file = "./temp/lingr_#{Time.now.to_i}.png"
		`phantomjs lingr_history_image.js #{url} #{file}`

		gyazo = Gyazo.new ""
		result = gyazo.upload file

		param = {
			room: room,
			bot: 'lingr_history_image',
			text: result,
			bot_verifier: ENV['BOT_KEY']
		}.tap {|p| p[:bot_verifier] = Digest::SHA1.hexdigest(p[:bot] + p[:bot_verifier]) }

		query_string = param.map {|e|
			e.map {|s| ERB::Util.url_encode s.to_s }.join '='
		}.join '&'
		open "http://lingr.com/api/room/say?#{query_string}"
	end
end



post '/lingr_bot' do
	content_type :text
	json = JSON.parse(request.body.string)
	json["events"].select {|e| e['message'] }.map {|e|
		text = e["message"]["text"]

		if lingr_history_url? text
			post_lingr(text, e["message"]["room"])
		end
	}
	return ""
end


