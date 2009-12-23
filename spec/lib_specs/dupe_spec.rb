require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dupe do
  before do
    Dupe.reset
  end
  
  describe "reset" do
    it "should reset @models to an empty hash" do
      Dupe.models.length.should == 0
      Dupe.define :book do |attrs|
        attrs.title
        attrs.author
      end
      Dupe.models.length.should == 1
      Dupe.reset
      Dupe.models.should == {}
    end
    
    it "should clear out the database" do
      Dupe.define :book
      Dupe.define :author
      Dupe.database.tables.length.should == 2
      Dupe.reset
      Dupe.database.tables.should be_empty
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
    end
    
    it "should add a table to the database" do
      Dupe.database.tables.length.should == 0
      Dupe.database.tables[:book].should be_nil
      Dupe.define :book
      Dupe.database.tables.length.should == 1
      Dupe.database.tables[:book].should_not be_nil
      Dupe.database.tables[:book].should == {}
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
      Dupe.database.tables[:book].values.length.should == 1
      Dupe.database.tables[:book].values.first.should == @book
    end
    
    it "should create several records if passed an array of hashes (and return an array of the records created)" do
      Dupe.define :book
      Dupe.database.tables[:book].should be_empty
      @books = Dupe.create :books, [{:title => 'Book 1'}, {:title => 'Book 2'}]
      Dupe.database.tables[:book].should_not be_empty
      Dupe.database.tables[:book].values.length.should == 2
      Dupe.database.tables[:book].values.first.should == @books.first
      Dupe.database.tables[:book].values.last.should == @books.last      
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
  
  
 
end