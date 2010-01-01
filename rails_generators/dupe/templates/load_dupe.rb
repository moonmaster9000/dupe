# First, load the definitions
Dir[File.join(File.dirname(__FILE__), '../dupe/definitions/*.rb')].each do |file|
  require file
end

# next, load the custom mocks
Dir[File.join(File.dirname(__FILE__), '../dupe/custom_mocks/*.rb')].each do |file|
  require file
end