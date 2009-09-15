require 'active_resource'
require 'active_resource/http_mock'
require 'dupe/string'
require 'dupe/dupe'
require 'dupe/sequence'
require 'dupe/mock_service_response'
require 'dupe/configuration'
require 'dupe/attribute'
require 'dupe/active_resource'
require 'dupe/cucumber_hooks'
require 'dupe/record'

path = defined?(RAILS_ROOT) ? RAILS_ROOT + '/features/dupe_definitions' : '../features/dupe_definitions'
if File.directory? path
  Dir[File.join(path, '*.rb')].each do |file|
    require file
  end
end
