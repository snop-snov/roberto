# bot.rb
require 'sinatra'
# require 'pry'

get '/' do
  data = { message: 'Hello!' }
  content_type :json
  data.to_json
end

post '/url_verification' do
  content_type :json
  json = parse_json(request.body.read)
  data = json.slice(:challenge)
  data.to_json
end

post '/url_verification' do
  data = params.slice(:challenge)
  content_type :json
  data.to_json
end

error JSON::ParserError do
  status 422
  { error: 'Invalid json' }
end

private

def parse_json(body)
  JSON.parse(body, symbolize_names: true)
end
