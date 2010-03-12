require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActiveResource::Connection do 
  before do
    Dupe.reset
  end
  
  describe "#get" do
    before do
      @book = Dupe.create :book, :title => 'Rooby', :label => 'rooby'
      class Book < ActiveResource::Base
        self.site = ''
      end
    end
    
    it "should pass a request off to the Dupe network if the original request failed" do            
      Dupe.network.should_receive(:request).with(:get, '/books.xml').once.and_return(Dupe.find(:books).to_xml(:root => 'books'))
      books = Book.find(:all)
    end
    
    it "should parse the xml and turn the result into active resource objects" do
      books = Book.find(:all)
      books.length.should == 1
      books.first.id.should == 1
      books.first.title.should == 'Rooby'
      books.first.label.should == 'rooby'
    end
  end
  
  describe "#post" do
    before do
      @book = Dupe.create :book, :label => 'rooby', :title => 'Rooby'
      @book.delete(:id)
      class Book < ActiveResource::Base
        self.site = ''
      end
    end
    
    it "should pass a request off to the Dupe network if the original request failed" do
      Dupe.network.should_receive(:request).with(:post, '/books.xml', Hash.from_xml(@book.to_xml(:root => 'book'))["book"] ).once
      book = Book.create({:label => 'rooby', :title => 'Rooby'})
    end
    
    it "should parse the xml and turn the result into active resource objects" do
      book = Book.create({:label => 'rooby', :title => 'Rooby'})
      book.id.should == 2
      book.title.should == 'Rooby'
      book.label.should == 'rooby'
    end
    
    it "should make ActiveResource throw an unprocessable entity exception if our Post mock throws a Dupe::UnprocessableEntity exception" do
      Post %r{/books\.xml} do |post_data|
        raise Dupe::UnprocessableEntity.new(:title => "must be present.") unless post_data["title"]
        Dupe.create :book, post_data
      end
      
      b = Book.create
      b.new?.should be_true
      b.errors.errors.should_not be_empty
      b = Book.create(:title => "hello")
      b.new?.should be_false
      b.errors.should be_empty
    end
  end
end