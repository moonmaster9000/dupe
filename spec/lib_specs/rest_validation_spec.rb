require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dupe::Network::RestValidation do
  before do
    class TestRestValidation
      include Dupe::Network::RestValidation
    end
  end
  
  describe "validate_request_type" do
    it "should raise an exception if the request type isn't :get, :post, :put, or :delete" do
      proc { 
        TestRestValidation.new.validate_request_type(:unknown_request_type) 
      }.should raise_error(Dupe::Network::UnknownRestVerbError)
    end
  end
end