# Author::    Matt Parker  (mailto:moonmaster9000@gmail.com)
# License::   Distributes under the same terms as Ruby

class Dupe

  class << self
    
    # the models you have defined via Dupe.define
    attr_reader :models
    
    # the database where all the records you've created via
    # Dupe.create are stored. 
    attr_reader :database
    
    # set this to "true" if you Dupe to spit out mocked requests
    # after each of your cucumber scenario's run
    attr_accessor :debug
    
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
    # default value 'Lorem ipsum delor.'. Also, it will transform the 'date_of_birth' value we provided in the hash 
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
    #     <bio>Lorem ipsum delor.</bio>
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
    #       <bio>Lorem ipsum delor.</bio>
    #       <date_of_birth>1917-12-16T00:00:00Z</date_of_birth>
    #     </author>
    #   </book>
    def define(*args, &block) # yield: define
      model_name, model_object = create_model_if_definition_parameters_are_valid(args, block)
      models[model_name] = model_object
      database.create_table model_name
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
    def create(model_name, records={})
      model_name = model_name.to_s.singularize.to_sym
      @models[model_name] = Dupe::Model.new(model_name) unless @models[model_name]
      results = []
      
      if records.kind_of?(Array)
        records.each do |record| 
          r = @models[model_name].create record
          database.insert r
          results << r
        end
        return results
      elsif records.kind_of?(Hash)
        r = @models[model_name].create records
        database.insert r
        return r
      else
        raise ArgumentError, "You must create with either a hash or an array of hashes."
      end
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
    #   {:name => 'default', :id => 1}
    #   ....
    #   {:name => 'default', :id => 20}
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
    #   {:name => 'author 1',   :id => 1}
    #   ....
    #   {:name => 'author 20',  :id => 20}
    #
    # You may also override the sequence starting value:
    #
    #   Dupe.stub 20, :authors, :like => {:name => proc {|n| "author #{n}"}}, :starting_with => 150
    #
    # This would generate 20 author records like:  
    #
    #   {:name => 'author 150',   :id => 1}
    #   ....
    #   {:name => 'author 169',  :id => 20}
    #
    # Naturally, stub will consult the Dupe.define definitions for anything it's attempting to stub
    # and will honor those definitions (default values, transformations) as you would expect. 
    def stub(count, factory, options={})
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
    # Had we instead specified <tt>find(:authors)</tt>, Dupe would have instead returned an array of results. 
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
    def find(model_name, &block) # yield: record
      results = database.select model_name.to_s.singularize.to_sym, block
      if model_name.to_s.pluralize == model_name.to_s
        results
      else
        results.first
      end
    end
    
    def models
      @models ||= {}
    end
    
    def database
      @database ||= Dupe::Database.new
    end
    
    def reset
      @models = {}
      @database = Dupe::Database.new
    end
    
    def debug
      @debug ||= false
    end
    
    private
    
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
