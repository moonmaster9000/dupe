require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dupe::Network::Mock do
  before do
    Dupe.reset
  end
  
  describe "new" do
    it "should require a valid REST type" do
      proc { Dupe::Network::Mock.new :unknown, /\//, proc {} }.should raise_error(Dupe::Network::UnknownRestVerbError)
      proc { Dupe::Network::Mock.new :get,     /\//, proc {} }.should_not raise_error
      proc { Dupe::Network::Mock.new :post,    /\//, proc {} }.should_not raise_error
      proc { Dupe::Network::Mock.new :put,     /\//, proc {} }.should_not raise_error
      proc { Dupe::Network::Mock.new :delete,  /\//, proc {} }.should_not raise_error
    end
    
    it "should require the url be a kind of regular expression" do
      proc { Dupe::Network::Mock.new :get, '', proc {} }.should raise_error(
        ArgumentError,
        "The URL pattern parameter must be a type of regular expression."
      )
    end
    
    it "should set the @verb, @url, and @response parameters accordingly" do
      url_pattern = /\//
      response = proc {}
      mock = Dupe::Network::Mock.new :get, url_pattern, response
      mock.verb.should == :get
      mock.url_pattern.should == url_pattern
      mock.response.should == response
    end
  end
  
  describe "match?" do
    it "should determine if a given string matches the mock's url pattern" do
      url = %r{/blogs/(\d+).xml}
      response = proc {}
      mock = Dupe::Network::Mock.new :get, url, response
      mock.match?('/blogs/1.xml').should == true
      mock.match?('/bogs/1.xml').should == false
    end
  end
  
  describe "mocked_response" do
    describe "on a mock object whose response returns a Dupe.find" do
      it "should convert the response result to xml" do
        url_pattern = %r{/books/(\d+)\.xml}
        response = proc {|id| Dupe.find(:book) {|b| b.id == id.to_i}}
        book = Dupe.create :book
        mock = Dupe::Network::Mock.new :get, url_pattern, response
        mock.mocked_response('/books/1.xml').should == book.to_xml(:root => 'book')
      end
      
      it "should add a request to the Dupe::Network#log" do
        url_pattern = %r{/books/([a-zA-Z0-9-]+)\.xml}
        response = proc {|label| Dupe.find(:book) {|b| b.label == label}}
        book = Dupe.create :book, :label => 'rooby'
        mock = Dupe::Network::Mock.new :get, url_pattern, response
        Dupe.network.log.requests.length.should == 0
        mock.mocked_response('/books/rooby.xml')
        Dupe.network.log.requests.length.should == 1
      end
    end
  end
  
  
end