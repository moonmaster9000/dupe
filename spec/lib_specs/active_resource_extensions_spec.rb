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
end