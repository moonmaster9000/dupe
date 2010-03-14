require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dupe::Database do
  before do
    Dupe.reset
  end
  
  describe "new" do
    before do
      @database = Dupe::Database.new
    end
    
    it "should initialize an empty table set" do
      @database.tables.should be_kind_of(Hash)
      @database.tables.should be_empty
    end
  end
  
  describe "delete" do
    before do 
      Dupe.stub 10, :books
    end

    it "should delete the first record found if the resource name is singular and there is no conditions proc" do
      Dupe.find(:books).length.should == 10
      Dupe.database.delete :book
      Dupe.find(:books).length.should == 9
    end

    it "should delete all records if the resource name is plural and there is no conditions proc" do
      Dupe.find(:books).length.should == 10
      Dupe.database.delete :books
      Dupe.find(:books).length.should == 0
    end

    it "should delete all matching records if there is a conditions proc and the resource name is singular" do
      Dupe.find(:books).length.should == 10
      Dupe.database.delete :book, proc {|b| b.id < 3}
      Dupe.find(:books).length.should == 8
    end

    it "should delete all matching records if there is a conditions proc and the resource name is plural" do
      Dupe.find(:books).length.should == 10
      Dupe.database.delete :books, proc {|b| b.id < 3}
      Dupe.find(:books).length.should == 8
    end
  end
  
  describe "insert" do
    before do
      Dupe.define :book
      @book = Dupe.models[:book].create :title => 'test'
      @database = Dupe::Database.new
    end
    
    it "should require a record" do
      proc {@database.insert}.should raise_error(ArgumentError)
      proc {
        @database.insert 'not a Dupe::Database::Record object'
      }.should raise_error(
        ArgumentError,
        "You may only insert well-defined Dupe::Database::Record objects"
      )
      proc {
        @database.insert Dupe::Database::Record.new
      }.should raise_error(
        ArgumentError,
        "You may only insert well-defined Dupe::Database::Record objects"
      )
      proc {@database.insert @book}.should_not raise_error
    end
    
    it "should create a new table if one does not already exist upon insert" do
      @database.tables.should be_empty
      @database.insert @book
      @database.tables[:book].should_not be_nil
      @database.tables[:book].should be_kind_of(Array)
      @database.tables[:book].should_not be_empty
      @database.tables[:book].first.should_not be_nil
      @database.tables[:book].first.should == @book
    end
  end
  
  describe "select" do
    before do
      Dupe.define :book
      @book = Dupe.models[:book].create :title => 'test'
      @database = Dupe::Database.new
      @database.insert @book
    end
    
    it "should require a valid model name" do
      proc { @database.select }.should raise_error(ArgumentError)
      proc { @database.select :undefined_model }.should raise_error(
        Dupe::Database::TableDoesNotExistError,
        "The table ':undefined_model' does not exist."
      )
      proc { @database.select :book }.should_not raise_error
    end
    
    it "should accept a conditions proc" do
      proc { @database.select :book, proc {|c| true} }.should_not raise_error
    end
    
    it "should verify that the conditions proc accepts a single parameter" do
      proc { @database.select :book, proc {true} }.should raise_error(
        Dupe::Database::InvalidQueryError,
        "There was a problem with your select conditions. Please consult the API."
      )
    end
    
    it "should find the requested items and return an array" do
      results = @database.select :book, proc {|b| b.title == 'test' }
      results.should be_kind_of(Array)
      results.should_not be_empty
      results.first.__model__.should == Dupe.models[:book]
      results.first.__model__.name.should == :book
      results.first.title.should == 'test'
      results.first.id.should == 1
    end
  end
  
  describe "create_table" do
    it "should create a database table if one doesn't already exist" do
      @database = Dupe::Database.new
      @database.tables.length.should == 0
      @database.tables[:book].should be_nil
      @database.create_table 'book'
      @database.tables[:book].should_not be_nil
      @database.tables.length.should == 1
      @database.tables[:book].should == []
      
      # make sure it doesn't overwrite a table that already exists
      m = Dupe::Model.new :book
      record = m.create
      @database.insert record
      @database.tables[:book].length.should == 1
      @database.tables[:book].first.should == record
      @database.create_table :book
      @database.tables[:book].length.should == 1
      @database.tables[:book].first.should == record
    end
  end
  
  describe "truncate_tables" do
    it "should remove all records from all tables" do
      Dupe.create :book
      Dupe.create :author
      Dupe.create :publisher
      Dupe.database.tables.length.should == 3
      Dupe.database.tables[:book].length.should == 1
      Dupe.database.tables[:author].length.should == 1
      Dupe.database.tables[:publisher].length.should == 1
      Dupe.database.truncate_tables
      Dupe.database.tables.length.should == 3
      Dupe.database.tables[:book].length.should == 0
      Dupe.database.tables[:author].length.should == 0
      Dupe.database.tables[:publisher].length.should == 0
    end
  end
  

end
