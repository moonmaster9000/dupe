class Dupe
  class Network    
    include RestValidation
    
    class RequestNotFoundError < StandardError; end
    
    attr_reader :mocks
    
    def initialize
      @mocks = {}
      VERBS.each { |verb| @mocks[verb] = [] }
    end
        
    def request(verb, url)
      validate_request_type verb
      match(verb, url).mocked_response(url)
    end
    
    def define_service_mock(verb, url_pattern, response_proc=nil)
      Mock.new(verb, url_pattern, response_proc).tap do |mock|
        @mocks[verb] << mock
      end
    end
    
    private
    def match(verb, url)
      @mocks[verb].each do |mock|
        return mock if mock.match?(url)
      end
      raise(
        RequestNotFoundError,
        "No mocked service response found for '#{url}'"
      )
    end
    
  end
end