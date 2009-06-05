require 'rubygems'
require 'sinatra'

Sinatra::Application.set(
  :environment => ENV['RACK_ENV'],
  :run => false
)

log = File.new(File.join(File.dirname(__FILE__), "#{ENV['RACK_ENV']}.log"), "a")
STDOUT.reopen(log)
STDERR.reopen(log)

require File.join(File.dirname(__FILE__), 'app')
run Sinatra::Application

