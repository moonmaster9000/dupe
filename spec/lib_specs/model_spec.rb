require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dupe::Model do
  describe "new" do
    it "should require a model name" do
      proc { Dupe::Model.new }.should raise_error(ArgumentError)
    end
    
    it "should set the model name to what was passed in during initialization" do
      m = Dupe::Model.new :book
      m.name.should == :book
    end
    
    it "should initialize an empty schema" do
      m = Dupe::Model.new :book
      m.schema.should be_kind_of(Dupe::Model::Schema)
    end
    
    it "should setup an id_sequence initialized to 0" do
      m = Dupe::Model.new :book
      m.id_sequence.current_value.should == 1
    end
  end
  
  describe "define" do
    describe "when passed a proc" do
      before do
        @model = Dupe::Model.new :book
        @definition = proc { |attrs|
          attrs.author('Anonymous') do |dont_care|
            'Flying Spaghetti Monster'
          end
        }
      end
      
      it "should pass that proc off to it's schema" do
        @model.schema.should_receive(:method_missing).once
        @model.define @definition
      end
      
      it "should result in a schema with the desired attribute templates" do
        @model.define @definition
        @model.schema.attribute_templates[:author].name.should == :author
        @model.schema.attribute_templates[:author].default.should == 'Anonymous'
        @model.schema.attribute_templates[:author].transformer.call(
          'dont care'
        ).should == 'Flying Spaghetti Monster'
      end
    end
  end
  
  describe "create" do
    before do 
      Dupe.define :book do |attrs|
        attrs.title 'Untitled'
        attrs.author 'Anon' do |author|
          "Author: #{author}"
        end
        attrs.after_create do |book|
          book.label = book.title.downcase.gsub(/\ +/, '-')
        end
      end
      
      @book_model = Dupe.models[:book]
    end
    
    it "shouldn't require any parameters" do
      proc {
        @book_model.create
      }.should_not raise_error
    end
    
    it "should return a Dupe::Database::Record instance with the desired parameters" do
      book = @book_model.create
      book.should be_kind_of(Dupe::Database::Record)
      book.__model__.name.should == :book
      book.id.should == 1
      book.title.should == 'Untitled'
      book.author.should == 'Anon'
      
      # the callback shouldn't get run until the database record is inserted into the duped 'database'
      book.label.should == nil
      
      book = @book_model.create :title => 'Rooby On Rails', :author => 'Matt Parker'
      book.__model__.name.should == :book
      book.id.should == 2
      book.title.should == 'Rooby On Rails'
      
      # the callback shouldn't get run until the database record is inserted into the duped 'database'
      book.label.should == nil
      
      book.author.should == 'Author: Matt Parker'
    end
  end
end