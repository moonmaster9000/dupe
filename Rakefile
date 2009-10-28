require 'rubygems'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name        = "dupe"
    gemspec.summary     = "A tool that helps you mock services while cuking."
    gemspec.description = "Dupe rides on top of ActiveResource to allow you to cuke the client side of 
                           a service-oriented app without having to worry about whether or not the service 
                           is live or available while cuking."
    gemspec.email       = "moonmaster9000@gmail.com"
    gemspec.files       = FileList['lib/**/*.rb', 'README.rdoc']
    gemspec.homepage    = "http://github.com/moonmaster9000/dupe"
    gemspec.authors     = ["Matt Parker"]
    gemspec.add_dependency('activeresource', '>= 2.3.3')
    gemspec.add_dependency('cucumber', '>= 0.3.98')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
