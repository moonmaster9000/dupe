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
    
    it "should initialize @log to a new Dupe::Network::Log" do
      @network.log.should be_kind_of(Dupe::Network::Log)
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
      proc { @network.request :post, '/some_url', 'some body' }.should_not raise_error(Dupe::Network::UnknownRestVerbError)
      proc { @network.request :put, '/some_url' }.should_not raise_error(Dupe::Network::UnknownRestVerbError)
      proc { @network.request :delete, '/some_url' }.should_not raise_error(Dupe::Network::UnknownRestVerbError)
    end
    
    it "should require a URL" do
      proc { @network.request :get }.should raise_error(ArgumentError)
      proc { @network.request :get, 'some_url'}.should_not raise_error(ArgumentError)
      proc { @network.request :post, 'some_url', 'some body'}.should_not raise_error(ArgumentError)
      proc { @network.request :put, 'some_url'}.should_not raise_error(ArgumentError)
      proc { @network.request :delete, 'some_url'}.should_not raise_error(ArgumentError)
    end
    
    it "should raise an exception if the network has no mocks that match the url" do
      proc { @network.request(:get, '/some_url')}.should raise_error(Dupe::Network::RequestNotFoundError)
      proc { @network.request(:post, '/some_url', 'some body')}.should raise_error(Dupe::Network::RequestNotFoundError)
      proc { @network.request(:put, '/some_url')}.should raise_error(Dupe::Network::RequestNotFoundError)
      proc { @network.request(:delete, '/some_url')}.should raise_error(Dupe::Network::RequestNotFoundError)
    end
    
    it "should return the appropriate mock response if a mock matches the url" do
      @network.define_service_mock :get, %r{/greeting$}, proc { "hello" }
      @network.request(:get, '/greeting').should == 'hello'
      
      @network.define_service_mock :post, %r{/greeting$}, proc { |post_data| Dupe.create(:greeting, post_data) }
      resp, url = @network.request(:post, '/greeting', {} )
      resp.should == Dupe.find(:greeting).to_xml_safe(:root => 'greeting')
      url.should == "/greetings/1.xml"
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
      proc { @network.define_service_mock :post, // }.should_not raise_error(Dupe::Network::UnknownRestVerbError)
      proc { @network.define_service_mock :put, // }.should_not raise_error(Dupe::Network::UnknownRestVerbError)
    end
    
    it "should require a valid Regexp url pattern" do
      proc { @network.define_service_mock :get, 'not a regular expression' }.should raise_error(ArgumentError)
      proc { @network.define_service_mock :post, 'not a regular expression' }.should raise_error(ArgumentError)
      proc { @network.define_service_mock :get, // }.should_not raise_error
      proc { @network.define_service_mock :post, // }.should_not raise_error
    end
    
    it "should create and return a new get service mock when given valid parameters" do
      verb = :get
      pattern = //
      response = proc { 'test' }
      @network.mocks[:get].should be_empty
      mock = @network.define_service_mock verb, pattern, response
      @network.mocks[:get].should_not be_empty
      @network.mocks[:get].first.class.should == Dupe::Network::GetMock
      @network.mocks[:get].length.should == 1
      @network.mocks[:get].first.should == mock
    end
    
    it "should create and return a new post service mock when given valid parameters" do
      verb = :post
      pattern = //
      response = proc { 'test' }
      @network.mocks[:post].should be_empty
      mock = @network.define_service_mock verb, pattern, response
      @network.mocks[:post].should_not be_empty
      @network.mocks[:post].first.class.should == Dupe::Network::PostMock
      @network.mocks[:post].length.should == 1
      @network.mocks[:post].first.should == mock
    end
    
    it "should create and return a new put service mock when given valid parameters" do
      verb = :put
      pattern = //
      response = proc { 'test' }
      @network.mocks[:put].should be_empty
      mock = @network.define_service_mock verb, pattern, response
      @network.mocks[:put].should_not be_empty
      @network.mocks[:put].first.class.should == Dupe::Network::PutMock
      @network.mocks[:put].length.should == 1
      @network.mocks[:put].first.should == mock
    end
    
    it "should create and return a new delete service mock when given valid parameters" do
      verb = :delete
      pattern = //
      response = proc { 'test' }
      @network.mocks[:delete].should be_empty
      mock = @network.define_service_mock verb, pattern, response
      @network.mocks[:delete].should_not be_empty
      @network.mocks[:delete].first.class.should == Dupe::Network::DeleteMock
      @network.mocks[:delete].length.should == 1
      @network.mocks[:delete].first.should == mock
    end
  end
  
end
