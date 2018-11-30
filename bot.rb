# bot.rb
require 'sinatra'
require 'slack-ruby-client'
# require 'pry'

require './lib/kick.rb'

Slack.configure do |config|
  config.token = ENV['SLACK_TOKEN']
end

get '/' do
  data = { message: 'Hello!' }
  content_type :json
  data.to_json
end

post '/messages' do
  content_type :json
  params = parse_json(request.body.read)
  case params[:type]
  when 'url_verification'
    data = params.slice(:challenge)
    data.to_json
  when 'message'
    Kick.perform(params[:text], params[:channel])
    200
  end
end

error JSON::ParserError do
  status 422
  { error: 'Invalid json' }
end

private

def parse_json(body)
  JSON.parse(body, symbolize_names: true)
end

def slack
  @slack ||= Slack::Web::Client.new
end
