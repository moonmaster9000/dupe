class Dupe
  class Network    #:nodoc:
    include RestValidation #:nodoc:
    
    class RequestNotFoundError < StandardError; end #:nodoc:
    
    attr_reader :mocks, :log
    
    def initialize
      @mocks = {}
      @log = Dupe::Network::Log.new
      VERBS.each { |verb| @mocks[verb] = [] }
    end
        
    def request(verb, url, body=nil)
      validate_request_type verb
      match(verb, url).mocked_response(url, body)
    end
    
    def define_service_mock(verb, url_pattern, response_proc=nil)
      validate_request_type verb
      case verb
      when :get
        GetMock.new(verb, url_pattern, response_proc).tap do |mock|
          @mocks[verb] << mock
        end
      when :post
        PostMock.new(verb, url_pattern, response_proc).tap do |mock|
          @mocks[verb].unshift mock
        end
      else
        raise StandardError, "Dupe does not (yet) support mocking #{verb.to_s.upcase} requests."
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