require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('dupe', '0.1.0') do |p|
  p.description = "Easily mock ActiveResource responses for testing purposes."
  p.url         = "http://github.com/moonmaster9000/dupe"
  p.author      = "Matt Parker"
  p.email       = "moonmaster9000@gmail.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
  p.runtime_dependencies = ["cucumber >=0.3.98", "activeresource >=2.3.3"]
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
