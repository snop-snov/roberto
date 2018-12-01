# frozen_string_literal: true

require 'sinatra'
require 'slack-ruby-client'
require 'net/http'
require 'pry'

require './lib/kick.rb'
require './lib/rpc.rb'

Slack.configure do |config|
  config.token = ENV['SLACK_TOKEN']
end

get '/' do
  data = {message: 'Hello!'}
  content_type :json
  data.to_json
end

post '/messages' do
  content_type :json
  data = parse_json(request.body.read)
  logger.info(params_info(data))

  case data[:type]
  when 'url_verification'
    data = data.slice(:challenge)
    data.to_json
  when 'event_callback'
    Kick.perform channel(data), message(data), users(data)
    200
  end
end

post '/buttons' do
  content_type :json
  data = parse_json(params['payload'])
  logger.info(data)

  case data[:type]
  when 'interactive_message'
    press_button_user = data[:user][:id]
    action = data[:actions].first[:value].to_sym
    Rpc.press_button(press_button_user, action, logger)
  end

  200
end

post '/kickass' do
  content_type :json
  data = params
  logger.info(data)

  Kick.perform channel(data), message(data), users(data)

  200
end

post '/rpc' do
  content_type :json
  data = params
  logger.info(data)

  channel = data[:channel_id]
  current_user = data[:user_id]
  users = data[:text].scan(/<\@(\w{3,})/).flatten

  Rpc.perform(channel, current_user, users)

  200
end

error JSON::ParserError do
  status 422
  {error: 'Invalid json'}
end

private

def parse_json(body)
  JSON.parse(body, symbolize_names: true)
end

def params_info(params)
  format('Request params: %<params>s', params: params)
end

def slack
  @slack ||= Slack::Web::Client.new
end

def channel(params)
  params[:event][:channel]
end

def message(params)
  event = params[:event]
  type = event[:type]

  return if type != 'message'

  subtype = event[:subtype]

  case subtype
  when nil
    event[:text]
  when 'message_changed'
    event[:message][:text]
  end
end

def users(params)
  m = message(params)
  return [] if m.nil?

  m.scan(/<\@([^>]*)>/).flatten
end

def wrap(user)
  "<@#{user}>"
end

def default_respond_to_button(action)
  response_data = {
    text: 'Accepted'
  }
  uri = URI.parse(action[:response_url])
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  headers = {'Content-Type': 'application/json'}
  request = Net::HTTP::Post.new(uri.request_uri, headers)
  request.body = response_data.to_json
  http.request(request)
end
