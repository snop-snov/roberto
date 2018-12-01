# frozen_string_literal: true

require 'sinatra'
require 'slack-ruby-client'
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
  params = parse_json(request.body.read)
  logger.info(params_info(params))

  case params[:type]
  when 'url_verification'
    data = params.slice(:challenge)
    data.to_json
  when 'event_callback'
    Kick.perform channel(params), message(params), users(params)
    Rpc.perform channel(params), message(params), users(params), current_user(params)
    200
  end
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
  massage = message(params)
  return [] if massage.nil?

  message.scan(/<\@([^>]*)>/).flatten
end

def wrap(user)
  "<@#{user}>"
end

def current_user(params)
  event = params[:event]
  event[:user] if event[:channel_type] == 'im'
end
