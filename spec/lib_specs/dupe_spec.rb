require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dupe do
  before do
    Dupe.reset
  end
  
  describe "reset" do
    it "should call reset_models, reset_database, and reset_network" do
      Dupe.should_receive(:reset_models).once
      Dupe.should_receive(:reset_database).once
      Dupe.should_receive(:reset_network).once
      Dupe.reset
    end
  end
  
  describe "reset_models" do
    it "should reset @models to an empty hash" do
      Dupe.models.length.should == 0
      Dupe.define :book do |attrs|
        attrs.title
        attrs.author
      end
      Dupe.models.length.should == 1
      Dupe.reset_models
      Dupe.models.should == {}
    end
  end
  
  describe "reset_database" do
    it "should clear out the database" do
      Dupe.define :book
      Dupe.define :author
      Dupe.database.tables.length.should == 2
      Dupe.reset_database
      Dupe.database.tables.should be_empty
    end    
  end
  
  describe "reset_network" do
    it "should clear out the network" do
      Dupe.create :book
      Dupe.network.mocks.values.inject(false) {|b,v| b || !v.empty?}.should == true
      Dupe.network.mocks[:get].should_not be_empty
      Dupe.reset_network
      Dupe.network.mocks.values.inject(false) {|b,v| b || !v.empty?}.should == false
    end    
  end
  
  describe "define" do
  
    # Dupe.define :model_name
    it "should accept a single symbol parameter" do
      proc {
        Dupe.define :book
      }.should_not raise_error
    end
  
    # Dupe.define :model_name do |attrs|
    #   attrs.attr1 'Default Value'
    #   attrs.attr2 do |value|
    #     'transformed value'
    #   end
    # end
    it "should accept a symbol plus a block (that accepts a single parameter)" do
      proc {
        Dupe.define :book do
        end
      }.should raise_error(
        ArgumentError,
        "Unknown Dupe.define parameter format. Please consult the API" + 
        " for information on how to use Dupe.define"
      )
    
      proc {
        Dupe.define :book do |attrs|
          attrs.author 'Anon'
          attrs.title 'Untitled'
        end
      }.should_not raise_error
    end
    
    it "should create a model and a schema with the desired definition" do
      Dupe.define :book do |attrs|
        attrs.author 'Anon'
        attrs.genre do
          'Unknown' + rand(2).to_s
        end
        attrs.title 'Untitled' do |value|
          "transformed #{value}"
        end
      end
      
      Dupe.models.length.should == 1
      Dupe.models[:book].schema.attribute_templates[:author].name.should == :author
      Dupe.models[:book].schema.attribute_templates[:author].default.should == 'Anon'
      Dupe.models[:book].schema.attribute_templates[:title].name.should == :title
      Dupe.models[:book].schema.attribute_templates[:title].default.should == 'Untitled'
      Dupe.models[:book].schema.attribute_templates[:title].transformer.should be_kind_of(Proc)
      Dupe.models[:book].schema.attribute_templates[:title].transformer.call('value').should == 'transformed value'
      Dupe.models[:book].schema.attribute_templates[:genre].name.should == :genre
      Dupe.models[:book].schema.attribute_templates[:genre].transformer.should be_nil
      Dupe.models[:book].schema.attribute_templates[:genre].default.should be_kind_of(Proc)
      Dupe.models[:book].schema.attribute_templates[:genre].default.call.should match(/^Unknown\d$/)
    end
    
    it "should add a table to the database" do
      Dupe.database.tables.length.should == 0
      Dupe.database.tables[:book].should be_nil
      Dupe.define :book
      Dupe.database.tables.length.should == 1
      Dupe.database.tables[:book].should_not be_nil
      Dupe.database.tables[:book].should == []
    end
    
    it "should add find(:all) and find(<id>) mocks to the database" do
      Dupe.network.mocks[:get].should be_empty
      Dupe.create :book
      Dupe.network.mocks[:get].should_not be_empty
      Dupe.network.mocks[:get].length.should == 2
      
      find_all_mock = Dupe.network.mocks[:get].first
      find_all_mock.verb.should == :get
      find_all_mock.url_pattern.should == %r{/books\.xml$}
      find_all_mock.mocked_response('/books.xml').should == Dupe.find(:books).to_xml(:root => 'books')
      
      find_one_mock = Dupe.network.mocks[:get].last
      find_one_mock.verb.should == :get
      find_one_mock.url_pattern.should == %r{/books/(\d+)\.xml$}
      find_one_mock.mocked_response('/books/1.xml').should == Dupe.find(:book).to_xml(:root => 'book')
    end
    
  end
  
  describe "create" do
    it "should require a model name parameter" do
      proc {Dupe.create}.should raise_error(ArgumentError)
      proc {Dupe.create :book}.should_not raise_error(ArgumentError)
    end
    
    it "should create a model if one doesn't already exist" do
      Dupe.models.should be_empty
      Dupe.create :book
      Dupe.models.should_not be_empty
      Dupe.models[:book].should_not be_nil
      Dupe.models[:book].name.should == :book
    end
    
    it "should be smart enough to singularize the model name before lookup/create" do
      Dupe.define :book
      Dupe.models.should_not be_empty
      Dupe.models.length.should == 1
      Dupe.models[:book].should_not be_nil
      Dupe.create :books
      Dupe.models.length.should == 1
      Dupe.models[:books].should be_nil
      Dupe.models[:book].should_not be_nil
      Dupe.create :authors
      Dupe.models.length.should == 2
      Dupe.models[:author].should_not be_nil
      Dupe.models[:author].name.should == :author
      Dupe.models[:authors].should be_nil
    end
    
    it "should create (and return) a database record if passed a single hash" do
      Dupe.define :book
      Dupe.database.tables[:book].should be_empty
      @book = Dupe.create :book, :title => 'test'
      Dupe.database.tables[:book].should_not be_empty
      Dupe.database.tables[:book].length.should == 1
      Dupe.database.tables[:book].first.should == @book
    end
    
    it "should create several records if passed an array of hashes (and return an array of the records created)" do
      Dupe.define :book
      Dupe.database.tables[:book].should be_empty
      @books = Dupe.create :books, [{:title => 'Book 1'}, {:title => 'Book 2'}]
      Dupe.database.tables[:book].should_not be_empty
      Dupe.database.tables[:book].length.should == 2
      Dupe.database.tables[:book].first.should == @books.first
      Dupe.database.tables[:book].last.should == @books.last      
    end
    
    it "should symbolize hash keys to keep from duplicating column names" do 
      b = Dupe.create :book, 'title' => 'War And Peace', :title => 'War And Peace'
      b.title.should == 'War And Peace'
      b[:title].should == 'War And Peace'
      b['title'].should == nil
      
      bs = Dupe.create :books, [{:test => 2, 'test' => 2}, {:test => 4, 'test' => 4}]
      bs.first.test.should == 2
      bs.first[:test].should == 2
      bs.first['test'].should == nil
      bs.last.test.should == 4
      bs.last[:test].should == 4
      bs.last['test'].should == nil
    end
  end
  
  describe "find" do
    before do
      Dupe.define :book
      @book = Dupe.create :book
    end
    
    it "should require a model name parameter" do
      proc { Dupe.find }.should raise_error(ArgumentError)
    end
    
    it "should require the model to exist" do
      proc { Dupe.find :unknown_models }.should raise_error(Dupe::Database::TableDoesNotExistError)
    end
    
    it "should return an array if you ask for a plural model (e.g., Dupe.find :books)" do
      result = Dupe.find :books
      result.should be_kind_of(Array)
      result.should_not be_empty
      result.length.should == 1
      result.first.should == @book
    end
    
    it "should return a single record (or nil) if you ask for a singular model (e.g., Dupe.find :book)" do
      result = Dupe.find :book
      result.should be_kind_of(Dupe::Database::Record)
      result.should == @book
      
      result = Dupe.find(:book) {|b| false}
      result.should be_nil
    end
  end
  
  describe "debug" do
    it "should default to false" do
      Dupe.debug.should == false
    end
    
    it "should allow you to set it to true" do
      Dupe.debug = true
      Dupe.debug.should == true
    end
    
    it "should persist across a Dupe.reset" do
      Dupe.debug = true
      Dupe.debug.should == true
      Dupe.reset
      Dupe.debug.should == true
    end
  end
  
  describe "stub" do
    it ": when called with only a count and a model_name, it should generate that many blank (id-only) records" do
      Dupe.database.tables[:author].should be_nil
      authors = Dupe.stub 20, :authors
      authors.length.should == 20
      Dupe.database.tables[:author].length.should == 20
      authors.collect(&:id).should == (1..20).to_a
    end
    
    it "should accept procs on stubs" do
      Dupe.database.tables[:author].should be_nil
      authors = 
        Dupe.stub(
          2, 
          :authors, 
          :like => {
            :name => proc {|n| "Author #{n}"},
            :bio => proc {|n| "Author #{n}'s bio"}
          }
        )
      authors.first.name.should == "Author 1"
      authors.first.bio.should == "Author 1's bio"
      authors.last.name.should == "Author 2"
      authors.last.bio.should == "Author 2's bio"
      Dupe.database.tables[:author].length.should == 2
    end
    
    it "shouldn't care if the model_name is singular or plural" do
      Dupe.database.tables.should be_empty
      Dupe.stub 5, :author
      Dupe.database.tables.should_not be_empty
      Dupe.database.tables.length.should == 1
      Dupe.database.tables[:author].length.should == 5
      Dupe.stub 5, :authors
      Dupe.database.tables[:author].length.should == 10
      Dupe.database.tables.length.should == 1
    end
  end
  
  describe "find_or_create" do
    it "should require a model name" do
      proc { Dupe.find_or_create }.should raise_error(ArgumentError)
    end
    
    it "should find a result if one exists" do
      b = Dupe.create :book, :title => 'Rooby', :serial_number => 21345
      found_book = Dupe.find_or_create :book, :title => 'Rooby', :serial_number => 21345
      b.should === found_book
      
      g = Dupe.create :genre, :name => 'Science Fiction', :label => 'sci-fi'
      found_genre = Dupe.find_or_create :genre, :name => 'Science Fiction', :label => 'sci-fi'
      g.should === found_genre
    end
    
    it "should create a result if one does not exist" do
      Dupe.database.tables.should be_empty
      author = Dupe.find_or_create :author, :name => 'Matt Parker', :age => 27, :label => 'matt-parker'
      Dupe.database.tables.should_not be_empty
      author.should === (Dupe.find(:author) {|a| a.label == 'matt-parker' && a.age == 27})
    end
    
    it "should return an array of results if passed a plural model name" do
      books = Dupe.stub 20, :books, :like => { :title => proc {|n| "book ##{n} title"} }
      bs = Dupe.find_or_create :books
      books.should == bs
    end
    
    it "should create and return an array of results if passed a plural model name for which no matching records exist" do
      Dupe.database.tables.should be_empty
      books = Dupe.find_or_create :books, :author => 'test'
      Dupe.database.tables.length.should == 1
      books.should be_kind_of(Array)
      books.should == Dupe.find(:books)
    end
    
  end
end