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
      @database.tables[:book].should be_kind_of(Hash)
      @database.tables[:book].should_not be_empty
      @database.tables[:book][1].should_not be_nil
      @database.tables[:book][1].should == @book
    end
  end
end
