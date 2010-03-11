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
      @book = Dupe.post :book, :label => 'rooby', :title => 'Rooby'
      class Book < ActiveResource::Base
        self.site = ''
      end
    end
    
    it "should pass a request off to the Dupe network if the original request failed" do
      Dupe.network.should_receive(:request).with(:post, '/books.xml', @book.to_xml(:root => 'book')).once.and_return(@book.to_xml(:root => 'book'))
      book = Book.create({:label => 'rooby', :title => 'Rooby'})
    end
    
    it "should parse the xml and turn the result into active resource objects" do
      book = Book.create({:label => 'rooby', :title => 'Rooby'})
      book.id.should == '1'
      book.title.should == 'Rooby'
      book.label.should == 'rooby'
    end
  end
  
  describe "#delete" do
    before do
      @book = Dupe.create :book, :label => 'rooby', :title => 'Rooby'
      class Book < ActiveResource::Base
        self.site = ''
      end
    end
    
    it "should pass a request off to the Dupe network if the original request failed" do
      book = Book.find(1)
      Dupe.network.should_receive(:request).with(:delete, '/books/1.xml').once.and_return(nil)
      book.destroy
    end
  end
end