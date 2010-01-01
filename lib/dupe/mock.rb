class Dupe
  class Network #:nodoc:
    class Mock #:nodoc:
      include Dupe::Network::RestValidation
      
      class ResourceNotFoundError < StandardError; end
      
      attr_reader :verb
      attr_reader :url_pattern
      attr_reader :response
    
      def initialize(verb, url_pattern, response_proc=nil)
        validate_request_type verb
        
        raise(
          ArgumentError,
          "The URL pattern parameter must be a type of regular expression."
        ) unless url_pattern.kind_of?(Regexp)
            
        @response = response_proc || proc {}
        @verb = verb
        @url_pattern = url_pattern
      end
    
      def match?(url)
        url_pattern =~ url ? true : false
      end
    
      def mocked_response(url)
        raise(
          StandardError, 
          "Tried to mock a response to a non-matched url! This should never occur. My pattern: #{@url_pattern}. Url: #{url}"
        ) unless match?(url)
      
        grouped_results = url_pattern.match(url)[1..-1]
        resp = @response.call *grouped_results
      
        case resp
          when NilClass
            raise ResourceNotFoundError, "Failed with 404: the request '#{url}' returned nil." 
          when Dupe::Database::Record
            resp = resp.to_xml(:root => resp.__model__.name.to_s)
          when Array
            if resp.empty?
              resp = [].to_xml :root => 'results'
            else
              resp = resp.to_xml(:root => resp.first.__model__.name.to_s.pluralize)
            end
        end
        
        Dupe.network.log.add_request @verb, url, resp
        
        resp
      end
    
    end
  end
end