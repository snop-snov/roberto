# bot.rb
require 'sinatra'

get '/' do
  data = { message: 'Hello!' }
  content_type :json
  data.to_json
end

post '/messages' do
  data = { message: 'Hello!' }
  content_type :json
  data.to_json
end

error JSON::ParserError do
  status 422
  { error: 'Invalid json' }
end
