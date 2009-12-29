require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Mock Definition Methods" do
  before do
    Dupe.reset
  end
  
  describe "Get" do    
    it "should require a url pattern that is a regex" do
      proc { Get() }.should raise_error(ArgumentError)
      proc { Get 'not a regexp' }.should raise_error(ArgumentError)
      proc { Get %r{/some_url} }.should_not raise_error
    end
    
    it "should create and return a Dupe::Network::Mock of type :get" do
      Dupe.network.mocks[:get].should be_empty
      @book = Dupe.create :book, :label => 'rooby'
      Dupe.network.mocks[:get].should_not be_empty
      Dupe.network.mocks[:get].length.should == 2
      
      mock = Get %r{/books/([^&]+)\.xml} do |label|
        Dupe.find(:book) {|b| b.label == label}
      end
      
      Dupe.network.mocks[:get].length.should == 3
      Dupe.network.mocks[:get].last.should == mock
      Dupe.network.mocks[:get].last.url_pattern.should == %r{/books/([^&]+)\.xml}
      book = Dupe.find(:book)
      Dupe.network.request(:get, '/books/rooby.xml').should == book.to_xml(:root => 'book')
    end
  end
end