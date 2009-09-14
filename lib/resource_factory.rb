require 'active_resource'
require 'active_resource/http_mock'
require 'resource_factory/resource_factory'
require 'resource_factory/sequence'
require 'resource_factory/mock_service_response'
require 'resource_factory/configuration'
require 'resource_factory/attribute'
require 'resource_factory/active_resource'
require 'resource_factory/cucumber_hooks'
require 'resource_factory/record'

path = defined?(RAILS_ROOT) ? RAILS_ROOT + '/features/resource_factory_definitions' : '../features/resource_factory_definitions'
if File.directory? path
  Dir[File.join(path, '*.rb')].each do |file|
    require file
  end
end
