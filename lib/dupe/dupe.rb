# Author::    Matt Parker  (mailto:moonmaster9000@gmail.com)
# License::   Distributes under the same terms as Ruby

class Dupe
  class << self
    
    attr_reader :models #:nodoc:
    attr_reader :sequences #:nodoc:
    attr_reader :database #:nodoc:
    
    # set this to "true" if you want Dupe to spit out mocked requests
    # after each of your cucumber scenario's run
    attr_accessor :debug
    
    # Suppose we're creating a 'book' resource. Perhaps our app assumes every book has a title, so let's define a book resource
    # that specifies just that:
    # 
    #   irb# Dupe.define :book do |attrs|
    #    --#   attrs.title 'Untitled'
    #    --#   attrs.author
    #    --# end
    #     ==> #<Dupe::Model:0x17b2694 ...>
    # 
    # Basically, this reads like "A book resource has a title attribute with a default value of 'Untitled'. It also has an author attribute." Thus, if we create a book and we don't specify a "title" attribute, it should create a "title" for us, as well as provide a nil "author" attribute.
    # 
    #   irb# b = Dupe.create :book
    #     ==> <#Duped::Book author=nil title="Untitled" id=1>
    # 
    # 
    # If we provide our own title, it should allow us to override the default value:
    # 
    #   irb# b = Dupe.create :book, :title => 'Monkeys!'
    #     ==> <#Duped::Book author=nil title="Monkeys!" id=2>
    # 
    # === Attributes with procs as default values
    # 
    # Sometimes it might be convenient to procedurally define the default value for an attribute:
    # 
    #   irb# Dupe.define :book do |attrs|
    #    --#   attrs.title 'Untitled'
    #    --#   attrs.author
    #    --#   attrs.isbn do
    #    --#     rand(1000000)
    #    --#   end
    #    --# end
    # 
    # Now, every time we create a book, it will get assigned a random ISBN number:
    # 
    #   irb# b = Dupe.create :book
    #     ==> <#Duped::Book author=nil title="Untitled" id=1 isbn=895825>
    # 
    #   irb# b = Dupe.create :book
    #     ==> <#Duped::Book author=nil title="Untitled" id=2 isbn=606472>
    # 
    # Another common use of this feature is for associations. Lets suppose we'd like to make sure that a book always has a genre, but a genre should be its own resource. We can accomplish that by taking advantage of Dupe's "find_or_create" method:
    # 
    #   irb# Dupe.define :book do |attrs|
    #    --#   attrs.title 'Untitled'
    #    --#   attrs.author
    #    --#   attrs.isbn do
    #    --#     rand(1000000)
    #    --#   end
    #    --#   attrs.genre do
    #    --#     Dupe.find_or_create :genre
    #    --#   end
    #    --# end
    # 
    # Now when we create books, Dupe will associate them with an existing genre (the first one it finds), or if none yet exist, it will create one. 
    # 
    # First, let's confirm that no genres currently exist: 
    # 
    #   irb# Dupe.find :genre
    #   Dupe::Database::TableDoesNotExistError: The table ':genre' does not exist.
    #     from /Library/Ruby/Gems/1.8/gems/dupe-0.4.0/lib/dupe/database.rb:30:in `select'
    #     from /Library/Ruby/Gems/1.8/gems/dupe-0.4.0/lib/dupe/dupe.rb:295:in `find'
    #     from (irb):135
    # 
    # Next, let's create a book:
    # 
    #   irb# b = Dupe.create :book
    #     ==> <#Duped::Book genre=<#Duped::Genre id=1> author=nil title="Untitled" id=1 isbn=62572>
    # 
    # Notice that it create a genre. If we tried to do another Dupe.find for the genre:
    # 
    #   irb# Dupe.find :genre
    #     ==> <#Duped::Genre id=1>
    # 
    # Now, if create another book, it will associate with the genre that was just created:
    # 
    #   irb# b = Dupe.create :book
    #     ==> <#Duped::Book genre=<#Duped::Genre id=1> author=nil title="Untitled" id=2 isbn=729317>
    # 
    # 
    # 
    # === Attributes with transformers
    # 
    # Occasionally, you may find it useful to have attribute values transformed upon creation. 
    # 
    # For example, suppose we want to create books with publish dates. In our cucumber scenario's, we may prefer to simply specify a date like '2009-12-29', and have that automatically transformed into an ruby Date object. 
    # 
    #   irb# Dupe.define :book do |attrs|
    #    --#   attrs.title 'Untitled'
    #    --#   attrs.author
    #    --#   attrs.isbn do
    #    --#     rand(1000000)
    #    --#   end
    #    --#   attrs.publish_date do |publish_date|
    #    --#     Date.parse(publish_date)
    #    --#   end
    #    --# end
    # 
    # Now, let's create a book:
    # 
    #   irb# b = Dupe.create :book, :publish_date => '2009-12-29'
    #     ==> <#Duped::Book author=nil title="Untitled" publish_date=Tue, 29 Dec 2009 id=1 isbn=826291>
    # 
    #   irb# b.publish_date
    #     ==> Tue, 29 Dec 2009
    # 
    #   irb# b.publish_date.class
    #     ==> Date
    #
    #
    #
    # === Uniquify attributes
    #
    # If you'd just like to make sure that some attributes get a unique value, then you can use the uniquify
    # method:
    # 
    #   irb# Dupe.define :book do |attrs|
    #    --#   attrs.uniquify :title, :genre, :author
    #    --# end
    # 
    # Now, Dupe will do its best to assign unique values to the :title, :genre, and :author attributes on 
    # any records it creates:
    # 
    #   irb# b = Dupe.create :book
    #     ==> <#Duped::Book author="book 1 author" title="book 1 title" genre="book 1 genre" id=1>
    # 
    #   irb# b2 = Dupe.create :book, :title => 'Rooby'
    #     ==> <#Duped::Book author="book 2 author" title="Rooby" genre="book 2 genre" id=2>
    # 
    #
    #
    # === Callbacks
    # 
    # Suppose we'd like to make sure that our books get a unique label. We can accomplish that with an after_create callback:
    # 
    #   irb# Dupe.define :book do |attrs|
    #    --#   attrs.title 'Untitled'
    #    --#   attrs.author
    #    --#   attrs.isbn do
    #    --#     rand(1000000)
    #    --#   end
    #    --#   attrs.publish_date do |publish_date|
    #    --#     Date.parse(publish_date)
    #    --#   end
    #    --#   attrs.after_create do |book|
    #    --#     book.label = book.title.downcase.gsub(/\ +/, '-') + "--#{book.id}"
    #    --#   end
    #    --# end
    # 
    #   irb# b = Dupe.create :book, :title => 'Rooby on Rails'
    #     ==> <#Duped::Book author=nil label="rooby-on-rails--1" title="Rooby on Rails" publish_date=nil id=1 isbn=842518>
    # 
    def define(*args, &block) # yield: define
      model_name, model_object = create_model_if_definition_parameters_are_valid(args, block)
      model_object.tap do |m|
        models[model_name] = m
        database.create_table model_name
        mocks = %{
          network.define_service_mock(
            :get, 
            %r{^#{model_name.to_s.titleize.constantize.prefix rescue '/'}#{model_name.to_s.pluralize}\\.xml$}, 
            proc { Dupe.find(:#{model_name.to_s.pluralize}) }
          )
          network.define_service_mock(
            :get, 
            %r{^#{model_name.to_s.titleize.constantize.prefix rescue '/'}#{model_name.to_s.pluralize}/(\\d+)\\.xml$}, 
            proc {|id| Dupe.find(:#{model_name}) {|resource| resource.id == id.to_i}}
          )
          network.define_service_mock(
            :post, 
            %r{^#{model_name.to_s.titleize.constantize.prefix rescue '/'}#{model_name.to_s.pluralize}\\.xml$}, 
            proc { |post_body| Dupe.create(:#{model_name.to_s}, post_body) }
          )
          network.define_service_mock(
            :put,
            %r{^#{model_name.to_s.titleize.constantize.prefix rescue '/'}#{model_name.to_s.pluralize}/(\\d+)\\.xml$}, 
            proc { |id, put_data| Dupe.find(:#{model_name.to_s}) {|resource| resource.id == id.to_i}.merge!(put_data) }
          )
          network.define_service_mock(
            :delete,
            %r{^#{model_name.to_s.titleize.constantize.prefix rescue '/'}#{model_name.to_s.pluralize}/(\\d+)\\.xml$}, 
            proc { |id| Dupe.delete(:#{model_name.to_s}) {|resource| resource.id == id.to_i} }
          )
        }
        eval(mocks)
      end
    end
   
    # This method will cause Dupe to mock resources for the record(s) provided. 
    # The "records" value may be either a hash or an array of hashes. 
    # For example, suppose you'd like to mock a single author: 
    #
    #   author = Dupe.create :author, :name => 'Arthur C. Clarke'
    #     ==> <#Duped::Author name="Arthur C. Clarke" id=1>
    #
    # This will translate into the following two mocked resource calls:
    #
    #   # GET /authors.xml
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <authors>
    #     <author>
    #       <id type="integer">1</id>
    #       <name>Arthur C. Clarke</name>
    #     </author>
    #   </authors>
    #   
    #   # GET /authors/1.xml
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <author>
    #     <id type="integer">1</id>
    #     <name>Arthur C. Clarke</name>
    #   </author>
    #
    # However, suppose you wanted to mock two or more authors. 
    # 
    #   authors = Dupe.create :author, [{:name => 'Arthur C. Clarke'}, {:name => 'Robert Heinlein'}]
    #     ==> [<#Duped::Author name="Arthur C. Clarke" id=1>, <#Duped::Author name="Robert Heinlein" id=2>]
    # 
    # This will translate into the following three mocked resource calls: 
    #
    #   # GET /authors.xml 
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
    #   # GET /authors/1.xml
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <author>
    #     <id type="integer">1</id>
    #     <name>Arthur C. Clarke</name>
    #   </author>
    #
    #   # GET /authors/2.xml
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <author>
    #     <id type="integer">2</id>
    #     <name>Robert Heinlein</name>
    #   </author>
    def create(model_name, records={})
      model_name = model_name.to_s.singularize.to_sym
      define model_name unless model_exists(model_name)
      records = records.kind_of?(Array) ? records.map {|r| r.symbolize_keys} : records.symbolize_keys!    
      create_and_insert records, :into => model_name
    end

    # You can use this method to quickly stub out a large number of resources. For example: 
    #
    #   Dupe.stub 20, :authors
    #
    #
    # Assuming you had an :author resource definition like: 
    #
    #   Dupe.define :author {|author| author.name('default')}
    #
    #
    # then stub would have generated 20 author records like: 
    #
    #   <#Duped::Author name="default" id=1>
    #   ....
    #   <#Duped::Author name="default" id=1>
    #
    # and it would also have mocked find(id) and find(:all) responses for these records (along with any other custom mocks you've
    # setup via Dupe.define_mocks). (Had you not defined an author resource, then the stub would have generated 20 author records
    # where the only attribute is the id). 
    #
    # Of course, it's more likely that you wanted to dupe 20 <em>different</em> authors. You can accomplish this by simply doing: 
    #   
    #   Dupe.stub 20, :authors, :like => {:name => proc {|n| "author #{n}"}}
    #
    # which would generate 20 author records like: 
    #
    #   <#Duped::Author name="author 1" id=1>
    #   ....
    #   <#Duped::Author name="author 20" id=20>
    #
    # Naturally, stub will consult the Dupe.define definitions for anything it's attempting to stub
    # and will honor those definitions (default values, transformations, callbacks) as you would expect. 
    def stub(count, model_name, options={})
      start_at = options[:starting_with] || 1
      record_template = options[:like] || {}
      records = []
      (start_at..(start_at + count - 1)).each do |i|
        records << 
          record_template.map do |k,v| 
            { k => (v.kind_of?(Proc) ? v.call(i) : v) }
          end.inject({}) {|h, v| h.merge(v)}
      end
      create model_name, records
    end

    # Dupe has a built-in querying system for finding resources you create. 
    #
    #   irb# a = Dupe.create :author, :name => 'Monkey'
    #     ==> <#Duped::Author name="Monkey" id=1>
    # 
    #   irb# b = Dupe.create :book, :title => 'Bananas', :author => a
    #     ==> <#Duped::Book author=<#Duped::Author name="Monkey" id=1> title="Bananas" id=1>
    # 
    #   irb# Dupe.find(:author) {|a| a.name == 'Monkey'}
    #     ==> <#Duped::Author name="Monkey" id=1>
    # 
    #   irb# Dupe.find(:book) {|b| b.author.name == 'Monkey'}
    #     ==> <#Duped::Book author=<#Duped::Author name="Monkey" id=1> title="Bananas" id=1>
    # 
    #   irb# Dupe.find(:author) {|a| a.id == 1}
    #     ==> <#Duped::Author name="Monkey" id=1>
    # 
    #   irb# Dupe.find(:author) {|a| a.id == 2}
    #     ==> nil
    # 
    # In all cases, notice that we provided the singular form of a model name to Dupe.find. 
    # This ensures that we either get back either a single resource (if the query was successful), or _nil_.
    # 
    # If we'd like to find several resources, we can use the plural form of the model name. For example:
    # 
    #   irb# a = Dupe.create :author, :name => 'Monkey', :published => true
    #     ==> <#Duped::Author published=true name="Monkey" id=1>
    # 
    #   irb# b = Dupe.create :book, :title => 'Bananas', :author => a
    #     ==> <#Duped::Book author=<#Duped::Author published=true name="Monkey" id=1> title="Bananas" id=1>
    # 
    #   irb# Dupe.create :author, :name => 'Tiger', :published => false
    #     ==> <#Duped::Author published=false name="Tiger" id=2>
    # 
    #   irb# Dupe.find(:authors)
    #     ==> [<#Duped::Author published=true name="Monkey" id=1>, <#Duped::Author published=false name="Tiger" id=2>]
    # 
    #   irb# Dupe.find(:authors) {|a| a.published == true}
    #     ==> [<#Duped::Author published=true name="Monkey" id=1>]
    # 
    #   irb# Dupe.find(:books)
    #     ==> [<#Duped::Book author=<#Duped::Author published=true name="Monkey" id=1> title="Bananas" id=1>]
    # 
    #   irb# Dupe.find(:books) {|b| b.author.published == false}
    #     ==> []
    # 
    # Notice that by using the plural form of the model name, we ensure that we receive back an array - 
    # even in the case that the query did not find any results (it simply returns an empty array).
    def find(model_name, &block) # yield: record
      results = database.select model_name.to_s.singularize.to_sym, block
      model_name.plural? ? results : results.first
    end
    
    # This method will create a resource with the given specifications if one doesn't already exist.
    # 
    #   irb# Dupe.find :genre
    #   Dupe::Database::TableDoesNotExistError: The table ':genre' does not exist.
    #     from /Library/Ruby/Gems/1.8/gems/dupe-0.4.0/lib/dupe/database.rb:30:in `select'
    #     from /Library/Ruby/Gems/1.8/gems/dupe-0.4.0/lib/dupe/dupe.rb:295:in `find'
    #     from (irb):40
    # 
    #   irb# Dupe.find_or_create :genre
    #     ==> <#Duped::Genre id=1>
    # 
    #   irb# Dupe.find_or_create :genre
    #     ==> <#Duped::Genre id=1>
    # 
    # You can also pass conditions to find_or_create as a hash:
    # 
    #   irb# Dupe.find_or_create :genre, :name => 'Science Fiction', :label => 'sci-fi'
    #     ==> <#Duped::Genre label="sci-fi" name="Science Fiction" id=2>
    # 
    #   irb# Dupe.find_or_create :genre, :name => 'Science Fiction', :label => 'sci-fi'
    #     ==> <#Duped::Genre label="sci-fi" name="Science Fiction" id=2>
    def find_or_create(model_name, attributes={})
      results = nil
      if model_exists(model_name)
        results = eval("find(:#{model_name}) #{build_conditions(attributes)}")
      end
      
      if !results
        if model_name.singular?
          create model_name, attributes
        else
          stub((rand(5)+1), model_name, :like => attributes)
        end
      elsif results.kind_of?(Array) && results.empty?
        stub((rand(5)+1), model_name, :like => attributes)
      else
        results
      end
    end

    def delete(resource, &conditions)
      database.delete resource, conditions 
    end

    def sequence(name, &block)
      sequences[name.to_sym] = Sequence.new 1, block
    end

    def next(name)
      raise ArgumentError, "Unknown sequence \":#{name}\"" unless sequences.has_key?(name)
      sequences[name].next
    end
        
    def models #:nodoc:
      @models ||= {}
    end
    
    def network #:nodoc:
      @network ||= Dupe::Network.new
    end
    
    def database #:nodoc:
      @database ||= Dupe::Database.new
    end

    def sequences #:nodoc:
      @sequences ||= {}
    end
    
    # clears out all model definitions, sequences, and database records / tables.
    def reset
      reset_models
      reset_database
      reset_network
      reset_sequences
    end
    
    def reset_sequences
      @sequences = {}
    end

    def reset_models
      @models = {}
    end
    
    def reset_database
      @database = Dupe::Database.new
    end
    
    def reset_network
      @network = Dupe::Network.new
    end
    
    # set to true if you want to see mocked results spit out after each cucumber scenario
    def debug
      @debug ||= false
    end
    
    
    
    private
    def build_conditions(conditions)
      return '' if conditions.empty?
      select = 
        "{|record| " +
        conditions.map do |k,v|
          "record.#{k} == #{v.kind_of?(String) ? "\"#{v}\"" : v}"
        end.join(" && ") + " }"
    end
    
    def model_exists(model_name)
      models[model_name.to_s.singularize.to_sym]
    end
    
    def create_model(model_name)
      models[model_name] = Dupe::Model.new(model_name) unless models[model_name]
    end
    
    def create_and_insert(records, into)
      raise(
        ArgumentError, 
        "You must pass a hash containing :into => :model_name " + 
        "as the second parameter to create_and_insert."
      ) if !into || !into.kind_of?(Hash) || !into[:into]
      
      # do we have several records to create, and are they each a hash?
      if records.kind_of?(Array) and
         records.inject(true) {|bool, r| bool and r.kind_of?(Hash)}
        [].tap do |results|
          records.each do |record| 
            results << models[into[:into]].create(record).tap {|r| database.insert r}
          end
        end
      
      # do we only have one record to create, and is it a hash?
      elsif records.kind_of?(Hash)
        models[into[:into]].create(records).tap {|r| database.insert r}
      
      else
        raise ArgumentError, "You must call Dupe.create with either a hash or an array of hashes."
      end
    end
    
    def create_model_if_definition_parameters_are_valid(args, definition)
      if args.length == 1 and
         args.first.kind_of?(Symbol) and
         definition == nil
        
        return args.first, Dupe::Model.new(args.first)
        
      elsif args.length == 1 and
         args.first.kind_of?(Symbol) and
         definition.kind_of?(Proc) and
         definition.arity == 1
        
        model_name = args.first
        return model_name, Dupe::Model.new(model_name).tap {|m| m.define definition}     
      
      else
        raise ArgumentError.new(
          "Unknown Dupe.define parameter format. Please consult the API for information on how to use Dupe.define"
        )
      end
    end
  end
end

class Dupe
  class UnprocessableEntity < StandardError; end
end
