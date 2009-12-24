require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dupe::Network do
  
  describe "new" do
    before do
      @network = Dupe::Network.new
    end
    
    it "should initialize @mocks to a hash of empty arrays keyed with valid REST verbs" do
      Dupe::Network::VERBS.each do |verb|
        @network.mocks[verb].should == []
      end
    end
  end
  
  describe "request" do
    before do
      @network = Dupe::Network.new
    end
    
    it "should require a valid REST verb" do
      proc { @network.request }.should raise_error
      proc { @network.request :invalid_rest_verb, '/some_url' }.should raise_error(Dupe::Network::UnknownRestVerbError)
      proc { @network.request :get, '/some_url' }.should_not raise_error(Dupe::Network::UnknownRestVerbError)
    end
    
    it "should require a URL" do
      proc { @network.request :get }.should raise_error(ArgumentError)
      proc { @network.request :get, 'some_url'}.should_not raise_error(ArgumentError)
    end
    
    it "should raise an exception if the network has no mocks that match the url" do
      proc { @network.request(:get, '/some_url')}.should raise_error(Dupe::Network::RequestNotFoundError)
    end
    
    it "should return the appropriate mock response if a mock matches the url" do
      @network.define_service_mock :get, %r{/greeting$}, proc { "hello" }
      @network.request(:get, '/greeting').should == 'hello'
    end
  end
  
  describe "define_service_mock" do
    before do
      @network = Dupe::Network.new
    end
    
    it "should require a valid REST verb" do
      proc { @network.define_service_mock }.should raise_error
      proc { @network.define_service_mock :invalid_rest_verb, // }.should raise_error(Dupe::Network::UnknownRestVerbError)
      proc { @network.define_service_mock :get, // }.should_not raise_error(Dupe::Network::UnknownRestVerbError)
    end
    
    it "should require a valid Regexp url pattern" do
      proc { @network.define_service_mock :get, 'not a regular expression' }.should raise_error(ArgumentError)
      proc { @network.define_service_mock :get, // }.should_not raise_error
    end
    
    it "should create and return a new service mock when given valid parameters" do
      verb = :get
      pattern = //
      response = proc { 'test' }
      @network.mocks[:get].should be_empty
      mock = @network.define_service_mock verb, pattern, response
      @network.mocks[:get].should_not be_empty
      @network.mocks[:get].length.should == 1
      @network.mocks[:get].first.should == mock
    end
    
    
  end
  
end