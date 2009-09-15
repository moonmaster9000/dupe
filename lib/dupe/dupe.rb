# Dupe allows you to define resources, create a pool of resources, 
# extend those resources with your own custom response mocks, and even override the default 
# mocks Dupe provides (<em>find(:all)</em> and <em>find(id)</em>). 
#
# Dupe is ideally suited for working with Cucumber[http://cukes.info]. It also relies on ActiveResource::HttpMock[http://api.rubyonrails.org/classes/ActiveResource/HttpMock.html] for mocking
# resource responses. 
#
# Let's suppose your cuking a book search application for a library that consumes a RESTFUL book datastore service via ActiveResource.
# You might start by writing the following feature in <em>RAILS_ROOT/features/library/find_book.feature</em>:
#
#   Feature: find a book
#     As a reader
#     I want to search for books
#     so that I can check them out and read them. 
#
#   Scenario: search by author
#     Given an author "Arthur C. Clarke"
#     And a book "2001: A Space Odyssey" by "Arthur C. Clarke"
#     When I search for "Arthur C. Clarke"
#     I should see "2001: A Space Odyssey"
#
# To get this to pass, you might first create an ActiveResource[http://api.rubyonrails.org/classes/ActiveResource/Base.html] model for a Book and an Author that will connect
# to the RESTful book service:
# 
#   class Book < ActiveResource::Base
#     self.site = 'http://bookservice.domain'
#   end
#
#   class Author < ActiveResource::Base
#     self.site = 'http://bookservice.domain'
#   end
#
# Then you might create the following resource definition via Dupe.define (put it in a file with a .rb extension and place it in RAILS_ROOT/features/support/):
#   
#   Dupe.define :book do |define|
#     define.author do |author_name|
#       Dupe.find(:author) {|a| a.name == author_name}
#     end
#   end
#
# and the following cucumber step definitions (utilizing Dupe.create):
#   
#   Given /^an author "([^\"]*)"$/ do |author|
#     Dupe.create :author, :name => author
#   end
#
#   Given /^a book "([^\"]*)" by "([^\"]*)"$/ do |book, author|
#     Dupe.create :book, :title => book, :author => author 
#   end
#
# Dupe.create will in turn mock two service responses for each resource. For example,
# for the Book resource, it will mock:
#
#   # Book.find(:all) --> GET /books.xml
#   <?xml version="1.0" encoding="UTF-8"?>
#   <books type="array">
#     <book>
#       <id type="integer">1</id>
#       <title>2001: A Space Odyssey</title>
#       <author>
#         <id type="integer">1</id>
#         <name>Arthur C. Clarke</name>
#       </author>
#     </book>
#   </books>
#
#   # Book.find(1) --> GET /books/1.xml
#   <?xml version="1.0" encoding="UTF-8"?>
#   <book>
#     <id type="integer">1</id>
#     <title>2001: A Space Odyssey</title>
#     <author>
#       <id type="integer">1</id>
#       <name>Arthur C. Clarke</name>
#     </author>
#   </book>

# Author::    Matt Parker  (mailto:moonmaster9000@gmail.com)
# License::   Distributes under the same terms as Ruby

class Dupe
  attr_reader :factory_name   #:nodoc:
  attr_reader :configuration  #:nodoc:
  attr_reader :attributes     #:nodoc:
  attr_reader :config         #:nodoc:
  attr_reader :mocker         #:nodoc:
  attr_reader :records        #:nodoc:

  class << self
    attr_accessor :factories            #:nodoc:
    attr_accessor :global_configuration #:nodoc:
    
    # Create data definitions for your resources. This allows you to setup default values for columns
    # and even provide data transformations.
    #
    # For example, suppose you had the following cucumber scenario: 
    #
    #   # RAILS_ROOT/features/library/find_book.feature
    #   Feature: Find a book
    #     As a reader
    #     I want to find books in my library
    #     So that I can read them
    #
    #   Scenario: Browsing books
    #     Given the following author: 
    #     | name             | date_of_birth |
    #     | Arthur C. Clarke | 1917-12-16    |
    #
    #     And the following book:
    #     | name                  | author            |
    #     | 2001: A Space Odyssey | Arthur C. Clarke  |
    #
    #     When....
    #
    #
    # We can use Dupe.define to
    # * Transform data (e.g., turn the string '1917-12-16' into a Date object)
    # * Provide default values for attributes (e.g., give all author's a default biography)
    # * Associate records (e.g., given an author name, return the author record associated with that name)
    #
    # To accomplish the afore mentioned definitions:
    #
    #   # RAILS_ROOT/features/dupe_definitions/book.rb
    #
    #   Dupe.define :author do |define|
    #     define.bio 'Lorem ipsum delor.'
    #     define.date_of_birth do |d|
    #       Date.parse(t)
    #     end
    #   end
    #   
    #   Dupe.define :book do |define|
    #     define.author do |author_name|
    #       Dupe.find(:author) {|a| a.name == author_name}
    #     end
    #   end
    #
    #   -----------------------------------------------------------------------------------------------------------------
    #
    #   # RAILS_ROOT/features/step_definitions/library/find_book_steps.rb
    #
    #   Given /^the following author:$/ do |author_table|
    #     Dupe.create(:author, author_table.hashes)
    #   end
    #
    #   Given /^the following book:$/ do |book_table|
    #     Dupe.create(:book, book_table.hashes)
    #   end
    #
    # When cucumber encounters the "Given the following author:" line, the corresponding step definition
    # will ask Dupe to mock ActiveResource responses to find(:all) and find(:id) with the data
    # specified in the cucumber hash table immediately following the "Given the following author:" line. 
    # Since we didn't specify a 'bio' value in our cucumber hash table, Dupe will give it the 
    # default value 'Bio stub.'. Also, it will transform the 'date_of_birth' value we provided in the hash 
    # table into a time object.
    #
    # Similarly, for the :book cucumber hash table, Dupe will transform the author name we provided
    # into the author object we had already specified in the :author table. 
    #
    # In terms of mocked responses, we could expect something like: 
    #
    #   # Author.find(1) --> GET /authors/1.xml
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <author>
    #     <id type="integer">1</id>
    #     <name>Arthur C. Clarke</name>
    #     <bio>Bio stub.</bio>
    #     <date_of_birth>1917-12-16T00:00:00Z</date_of_birth>
    #   </author>
    #
    #   # Book.find(1) --> GET /books/1.xml
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <book>
    #     <id type="integer">1</id>
    #     <name>2001: A Space Odyssey</name>
    #     <author>
    #       <id type="integer">1</id>
    #       <name>Arthur C. Clarke</name>
    #       <bio>Bio stub.</bio>
    #       <date_of_birth>1917-12-16T00:00:00Z</date_of_birth>
    #     </author>
    #   </book>
    def define(factory) # yield: define
      setup_factory(factory)
      yield @factories[factory]
    end
   
    # This method will cause Dupe to mock resources for the record(s) provided. 
    # The "records" value may be either a hash or an array of hashes. 
    # For example, suppose you'd like to mock a single author ActiveResource object: 
    #
    #   Dupe.create :author, :name => 'Arthur C. Clarke'
    #
    # This will translate into the following two mocked resource calls:
    #
    #   # Author.find(:all) --> GET /authors.xml
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <authors>
    #     <author>
    #       <id type="integer">1</id>
    #       <name>Arthur C. Clarke</name>
    #     </author>
    #   </authors>
    #   
    #   # Author.find(1) --> GET /authors/1.xml
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <author>
    #     <id type="integer">1</id>
    #     <name>Arthur C. Clarke</name>
    #   </author>
    #
    # However, suppose you wanted to mock two or more authors. 
    #
    #   Dupe.create :author, [{:name => 'Arthur C. Clarke'}, {:name => 'Robert Heinlein'}]
    #
    # This will translate into the following three mocked resource calls: 
    #
    #   # Author.find(:all) --> GET /authors.xml 
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <authors>
    #     <author>
    #       <id type="integer">1</id>
    #       <name>Arthur C. Clarke</name>
    #     </author>
    #     <author>
    #       <id type="integer">2</id>
    #       <name>Robert Heinlein</name>
    #     </author>
    #   </authors>
    #   
    #   # Author.find(1) --> GET /authors/1.xml
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <author>
    #     <id type="integer">1</id>
    #     <name>Arthur C. Clarke</name>
    #   </author>
    #
    #   # Author.find(2) --> GET /authors/2.xml
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <author>
    #     <id type="integer">2</id>
    #     <name>Robert Heinlein</name>
    #   </author>
    def create(factory, records={})
      setup_factory(factory)
      raise Exception, "unknown records type" if !records.nil? and !records.is_a?(Array) and !records.is_a?(Hash)
      records = [records] if records.is_a?(Hash)
      @factories[factory].generate_services_for(records)
    end

    # You can use this method to quickly stub out a large number of resources. For example: 
    #
    #   Dupe.stub(
    #     :author,
    #     :template => {:name => 'author'},
    #     :count    => 20
    #   )
    #
    # would generate 20 author records like: 
    #
    #   {:name => 'author 1', :id => 1}
    #   ....
    #   {:name => 'author 20', :id => 20}
    #
    # and it would also mock find(id) and find(:all) responses for these records (along with any other custom mocks you've
    # setup via Dupe.define_mocks).
    #
    # You may override both the sequence starting value and the attribute to sequence:
    #
    #   Dupe.stub(
    #     :book,
    #     :template => {:author => 'Arthur C. Clarke', :title => 'moonmaster'},
    #     :count    => 20,
    #     :sequence_start_value => 9000,     
    #     :sequence => :title
    #   )
    #
    # This would generate 20 book records like: 
    #
    #   {:id => 1, :author => 'Arthur C. Clarke', :title => 'moonmaster 9000'}
    #   ....
    #   {:id => 20, :author => 'Arthur C. Clarke', :title => 'moonmaster 9019'}
    #
    # Naturally, stub will consult the Dupe.define definitions for anything it's attempting to stub
    # and will honor those definitions (default values, transformations) as you would expect. 
    def stub(factory, options)
      setup_factory(factory)
      @factories[factory].stub_services_with(options[:template], options[:count].to_i, (options[:sequence_start_value] || 1), options[:sequence])
    end

    # === Global Configuration
    #
    # On a global level, configure supports the following options (expect this list to grow as the app grows):
    #   debug: list the attempted requests and mocked responses that happened during the course of a scenario
    #
    # To turn on debugging, simply do:
    #   Dupe.configure do |global_config|
    #     global_config.debug true
    #   end
    #
    # === Factory Configuration 
    #
    # On a factory level, configure support the following options (expect this list to grow as the app grows):
    #   record_identifiers: a list of attributes that are unique to each record in that resource factory.
    #   
    # The "record_identifiers" configuration option allows you to override the array record identifiers for your resources ([:id], by default)
    # 
    # For example, suppose the RESTful application your trying to consume supports lookups by both a textual 'label' 
    # and a numeric 'id', and that it contains an author service where the author with id '1' has the label 'arthur-c-clarke'.
    # Your application should expect the same response whether or not you call <tt>Author.find(1)</tt> or <tt>Author.find('arthur-c-clarke')</tt>.
    # 
    # Thus, to ensure that Dupe mocks both, do the following:
    #   Dupe.configure :author do |configure|
    #     configure.record_identifiers :id, :label
    #   end
    #
    # With this configuration, a <tt>Dupe.create :author, :name => 'Arthur C. Clarke', :label => 'arthur-c-clarke'</tt>
    # will result in the following mocked service calls: 
    #
    # <tt>Author.find(1) --> (GET /authors/1.xml)</tt>
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <author>
    #     <id type="integer">1</id>
    #     <name>Arthur C. Clarke</name>
    #     <label>arthur-c-clarke</label>
    #   </author>
    #
    #
    # <tt>Author.find('arthur-c-clarke') --> (GET /authors/arthur-c-clarke.xml)</tt>
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <author>
    #     <id type="integer">1</id>
    #     <name>Arthur C. Clarke</name>
    #     <label>arthur-c-clarke</label>
    #   </author>
    def configure(factory=nil) # yield: configure
      yield global_configuration and return unless factory
      setup_factory(factory)
      yield @factories[factory].config
    end
    
    # By default, Dupe will mock responses to ActiveResource <tt>find(:all)</tt> and <tt>find(id)</tt>. 
    # However, it's likely that your cucumber scenarios will eventually fire off an ActiveResource request that's
    # something other than these basic lookups.
    #
    # Dupe.define_mocks allows you to add new resource mocks and override the built-in resource mocks. 
    #
    # For example, suppose you had a Book ActiveResource model, and you want to use it to get the :count of all 
    # Books in the back end system your consuming. <tt>Book.get(:count)</tt> would fire off an HTTP request to the 
    # backend service like <tt>"GET /books/count.xml"</tt>, and assuming the service is set up to respond to that
    # request, you might expect to get something back like: 
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <hash>
    #     <count type="integer">3</count>
    #   </hash>
    #
    # To mock this for the purposes of cuking, you could do the following:
    # 
    #   Dupe.define_mocks :book do |define|
    #     define.count do |mock, records|
    #       mock.get "/books/count.xml", {}, {:count => records.size}.to_xml 
    #     end
    #   end
    #
    # The <tt>mock</tt> object is the ActiveResource::HttpMock object. Please see the documentation for that
    # if you would like to know more about what's possible with it. 
    def define_mocks(factory) # yield: define
      setup_factory(factory)
      yield @factories[factory].mocker
    end
    

    # Search for a resource. This works a bit differently from both ActiveRecord's find and ActiveResource's find. 
    # This is most often used for defining associations between objects (Dupe.define). 
    # It will return a hash representation of the resource (or an array of hashes if we asked for multiple records).
    #
    # For example, suppose we have an author resource, and a book resource with a nested author attribute (in ActiveRecord
    # parlance, Book belongs_to Author, Author has_many Book). 
    #
    # Now suppose we've created the following cucumber scenario:
    #
    #   Scenario: Browsing books
    #     Given the following author: 
    #     | name             | date_of_birth |
    #     | Arthur C. Clarke | 1917-12-16    |
    #
    #     And the following books:
    #     | name                  | author           | published | genre    |
    #     | 2001: A Space Odyssey | Arthur C. Clarke | 1968      | sci-fi   |
    #     | A Fall of Moondust    | Arthur C. Clarke | 1961      | fantasy  |
    #     | Rendezvous with Rama  | Arthur C. Clarke | 1972      | sci-fi   |
    #
    #     When....
    #
    # To link up the book and author, we could create the following book definition
    #   
    #   Dupe.define :book do |book|
    #     book.author {|name| Dupe.find(:author) {|a| a.name == name}}
    #   end
    # 
    # The line <tt>Dupe.find(:author) {|a| a.name == name}</tt> could be translated as 
    # "find the first author record where the author's name equals `name`". 
    #
    # Dupe decided to return only a single record because we specified <tt>find(:author)</tt>. 
    # Had we instead specified <tt>find(:authors)</tt>, resource factory would have instead returned an array of results. 
    #
    # More examples: 
    #   
    #   # find all books written in the 1960's
    #   Dupe.find(:books) {|b| b.published >= 1960 and b.published <= 1969}
    #
    #   # return the first book found that was written by Arthur C. Clarke (nested resources example)
    #   Dupe.find(:book) {|b| b.author.name == 'Arthur C. Clarke'}
    #
    #   # find all sci-fi and fantasy books
    #   Dupe.find(:books) {|b| b.genre == 'sci-fi' or b.genre == 'fantasy'}
    #
    #   # find all books written by people named 'Arthur'
    #   Dupe.find(:books) {|b| b.author.name.match /Arthur/}
    #
    # Also, if you have the need to explicitly specify :all or :first instead of relying on specifying the singular v. plural 
    # version of your resource name (perhaps the singular and plural version of your resource are exactly the same):
    # 
    #   Dupe.find(:all, :deer) {|d| d.type == 'doe'}
    #   Dupe.find(:first, :deer) {|d| d.name == 'Bambi'}
    def find(*args, &block) # yield: record
      all_or_first, factory_name = args[-2], args[-1]
      match         = block ? block : proc {true}
      all_or_first  = ((factory_name.to_s.pluralize == factory_name.to_s) ? :all : :first) unless all_or_first
      factory_name  = factory_name.to_s.singularize.to_sym
      verify_factory_exists factory_name
      result        = factories[factory_name].find_records_like match
      all_or_first  == :all ? result : result.first
    end

    def get_factory(factory) #:nodoc:
      setup_factory(factory)
      @factories[factory]
    end

    def flush(factory=nil, destroy_definitions=false) #:nodoc:
      if factory and factories[factory]
        factories[factory].flush(destroy_definitions)
      else
        factories.each {|factory_name, factory| factory.flush(destroy_definitions)}
      end
    end

    def factories #:nodoc:
      @factories ||= {}
    end

    def global_configuration #:nodoc:
      @global_configuration ||= Configuration.new
    end

    private
    
    def setup_factory(factory)
      factories[factory] = Dupe.new(factory) unless factories[factory]
    end

    def reset(factory)
      factories[factory].flush if factories[factory]
    end

    def verify_factory_exists(factory_name)
      raise "Dupe doesn't know about the '#{factory_name}' resource" unless factories[factory_name]
    end
  end

  def flush(destroy_definitions=false) #:nodoc:
    @records = []
    @sequence = Sequence.new
    @attributes = {} if destroy_definitions
    ActiveResource::HttpMock.reset_from_dupe!
  end
  
  def stub_services_with(record_template, count=1, starting_value=1, sequence_attribute=nil) #:nodoc:
    sequence_attribute ||= record_template.keys.first
    records = stub_records(record_template, count, starting_value, sequence_attribute)
    generate_services_for(records, true)
  end
  
  def initialize(factory) #:nodoc:
    @factory_name = factory
    @attributes   = {}
    @config       = Configuration.new
    @mocker       = MockServiceResponse.new(@factory_name)
    @records      = []
  end

  def method_missing(method_name, *args, &block) #:nodoc:
    args = [nil] if args.empty?
    args << block
    define_attribute(method_name.to_sym, *args)
  end

  def generate_services_for(records, records_already_processed=false) #:nodoc:
    records = process_records records unless records_already_processed
    @mocker.run_mocks(@records, @config.config[:record_identifiers])
  end
  
  def find_records_like(match) #:nodoc:
    @records.select {|r| match.call Record.new(r)}
  end

  private
  def define_attribute(name, default_value=nil, prock=nil) 
    @attributes[name] = Attribute.new(name, default_value, prock)
  end

  def process_records(records)
    records.map {|r| generate_record({:id => sequence}.merge(r))}
  end

  def generate_record(overrides={})
    define_missing_attributes(overrides.keys)
    record = {}
    @attributes.each do |attr_key, attr_class|
      override_default_value = overrides[attr_key] || overrides[attr_key.to_s]
      record[attr_key] = attr_class.value(override_default_value)
    end
    @records << record
    record
  end

  def sequence
    (@sequence ||= Sequence.new).next
  end

  def define_missing_attributes(keys)
    keys.each {|k| define_attribute(k.to_sym) unless @attributes[k.to_sym]}
  end

  def stub_records(record_template, count, starting_value, sequence_attribute)
    overrides = record_template.merge({sequence_attribute => (record_template[sequence_attribute].to_s + starting_value.to_s), :id => sequence})
    return [generate_record(overrides)] if count <= 1
    [generate_record(overrides)] + stub_records(record_template, count-1, starting_value+1, sequence_attribute)
  end

end