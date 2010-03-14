# Dupe knows how to handle simple find by id and find :all lookups from ActiveResource. But what about other requests we might potentially make? 
# 
#   irb# Dupe.create :author, :name => 'Monkey', :published => true
#     ==> <#Duped::Author name="Monkey" published=true id=1>
# 
#   irb# Dupe.create :author, :name => 'Tiger', :published => false
#     ==> <#Duped::Author name="Tiger" published=false id=2>
# 
#   irb# class Author < ActiveResource::Base; self.site = ''; end
#     ==> ""
# 
#   irb# Author.find :all, :from => :published
#   Dupe::Network::RequestNotFoundError: No mocked service response found for '/authors/published.xml'
#     from /Library/Ruby/Gems/1.8/gems/dupe-0.4.0/lib/dupe/network.rb:32:in `match'
#     from /Library/Ruby/Gems/1.8/gems/dupe-0.4.0/lib/dupe/network.rb:17:in `request'
#     from /Library/Ruby/Gems/1.8/gems/dupe-0.4.0/lib/dupe/active_resource_extensions.rb:15:in `get'
#     from /Library/Ruby/Gems/1.8/gems/activeresource-2.3.5/lib/active_resource/custom_methods.rb:57:in `get'
#     from /Library/Ruby/Gems/1.8/gems/activeresource-2.3.5/lib/active_resource/base.rb:632:in `find_every'
#     from /Library/Ruby/Gems/1.8/gems/activeresource-2.3.5/lib/active_resource/base.rb:582:in `find'
#     from (irb):12
# 
# Obviously, Dupe had no way of anticipating this possibility. However, you can create your own custom intercept mock for this: 
# 
#   irb# Get %r{/authors/published.xml} do
#    --#   Dupe.find(:authors) {|a| a.published == true}
#    --# end
#     ==> #<Dupe::Network::Mock:0x1833e88 @url_pattern=/\/authors\/published.xml/, @verb=:get, @response=#<Proc:0x01833f14@(irb):13>
# 
#   irb# Author.find :all, :from => :published
#     ==> [#<Author:0x1821d3c @attributes={"name"=>"Monkey", "published"=>true, "id"=>1}, prefix_options{}]
# 
#   irb# puts Dupe.network.log.pretty_print
# 
#     Logged Requests:
#       Request: GET /authors/published.xml
#       Response:
#         <?xml version="1.0" encoding="UTF-8"?>
#         <authors type="array">
#           <author>
#             <name>Monkey</name>
#             <published type="boolean">true</published>
#             <id type="integer">1</id>
#           </author>
#         </authors>
# 
# 
# The "Get" method requires a url pattern and a block. In most cases, your block will return a Dupe.find result. Internally, Dupe will transform that into XML. However, if your "Get" block returns a string, Dupe will use that as the response body and not attempt to do any transformations on it. 
# 
# Suppose instead the service expected us to pass published as a query string parameter:
# 
#   irb# Author.find :all, :params => {:published => true}
#   Dupe::Network::RequestNotFoundError: No mocked service response found for '/authors.xml?published=true'
#     from /Library/Ruby/Gems/1.8/gems/dupe-0.4.0/lib/dupe/network.rb:32:in `match'
#     from /Library/Ruby/Gems/1.8/gems/dupe-0.4.0/lib/dupe/network.rb:17:in `request'
#     from /Library/Ruby/Gems/1.8/gems/dupe-0.4.0/lib/dupe/active_resource_extensions.rb:15:in `get'
#     from /Library/Ruby/Gems/1.8/gems/activeresource-2.3.5/lib/active_resource/base.rb:639:in `find_every'
#     from /Library/Ruby/Gems/1.8/gems/activeresource-2.3.5/lib/active_resource/base.rb:582:in `find'
#     from (irb):18
# 
# We can mock this with the following:
# 
#   irb# Get %r{/authors\.xml\?published=(true|false)$} do |published|
#    --#   if published == 'true'
#    --#     Dupe.find(:authors) {|a| a.published == true}
#    --#   else
#    --#     Dupe.find(:authors) {|a| a.published == false}
#    --#   end
#    --# end
# 
#   irb# Author.find :all, :params => {:published => true}
#     ==> [#<Author:0x17db094 @attributes={"name"=>"Monkey", "published"=>true, "id"=>1}, prefix_options{}]
# 
#   irb# Author.find :all, :params => {:published => false}
#     ==> [#<Author:0x17c68c4 @attributes={"name"=>"Tiger", "published"=>false, "id"=>2}, prefix_options{}]
# 
#   irb# puts Dupe.network.log.pretty_print
#   
#     Logged Requests:
#       Request: GET /authors.xml?published=true
#       Response:
#         <?xml version="1.0" encoding="UTF-8"?>
#         <authors type="array">
#           <author>
#             <name>Monkey</name>
#             <published type="boolean">true</published>
#             <id type="integer">1</id>
#           </author>
#         </authors>
# 
#       Request: GET /authors.xml?published=false
#       Response:
#         <?xml version="1.0" encoding="UTF-8"?>
#         <authors type="array">
#           <author>
#             <name>Tiger</name>
#             <published type="boolean">false</published>
#             <id type="integer">2</id>
#           </author>
#         </authors>


def Get(url_pattern, &block)
  Dupe.network.define_service_mock :get, url_pattern, block
end

def Post(url_pattern, &block)
  Dupe.network.define_service_mock :post, url_pattern, block
end

def Put(url_pattern, &block)
  Dupe.network.define_service_mock :put, url_pattern, block
end

def Delete(url_pattern, &block)
  Dupe.network.define_service_mock :delete, url_pattern, block
end
