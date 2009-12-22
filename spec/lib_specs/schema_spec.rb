require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dupe::Model::Schema do
  describe "new" do
    it "should create an object that is a type of Hash" do
      Dupe::Model::Schema.new.should be_kind_of(Hash)
    end
    
    it "should accept a hash of key value pairs and map those to accessible instance variables" do
      book_schema = Dupe::Model::Schema.new(:title => 'Untitled')
      book_schema.title.should == 'Untitled'
    end
    
    it "should allow you to add value transformers to each value" do
      book_schema = Dupe::Model::Schema.new
      book_schema.publish_date do |value|
        if value.kind_of?(String)
          Date.parse(value) rescue value
        else
          value
        end
      end
      
      book_schema.publish_date = '2009-12-17'
      book_schema.publish_date.should be_kind_of(Date)
      book_schema.publish_date = '2009-12-17'
    end
  end
end