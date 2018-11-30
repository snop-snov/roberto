# frozen_string_literal: true

require 'sinatra'
require 'slack-ruby-client'
require 'pry'

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
  logger.info(params_info(params))

  case params[:type]
  when 'url_verification'
    data = params.slice(:challenge)
    data.to_json
  when 'event_callback'
    Kick.perform(params[:event])
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

def params_info(params)
  format('Request params: %<params>s', params: params)
end

def slack
  @slack ||= Slack::Web::Client.new
end
