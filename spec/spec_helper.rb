$LOAD_PATH.unshift './lib'
puts $LOAD_PATH.inspect
require 'rubygems'
gem 'activeresource'
gem 'rspec'
gem 'cucumber'
require 'cucumber'
require 'active_resource'
require 'dupe'