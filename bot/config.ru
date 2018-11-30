require 'rubygems'
require 'bundler'

Bundler.require

require './bot'
run Sinatra::Application
