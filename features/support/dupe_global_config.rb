Dupe.configure do |global_config|
  global_config.debug true
end

class PrefixBook < ActiveResource::Base
  self.site = "http://blah/book_services"
end
