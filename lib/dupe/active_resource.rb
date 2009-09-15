# this allows us to control when we flush out the HttpMock requests / responses
ActiveResource::HttpMock.instance_eval do #:nodoc:
  def reset! #:nodoc:
  end

  def reset_from_dupe! #:nodoc:
    requests.clear
    responses.clear
  end
end

# makes it possible to override existing request/response definitions
module ActiveResource #:nodoc:
  class HttpMock      #:nodoc:
    class Responder   #:nodoc:
      for method in [ :post, :put, :get, :delete, :head ]
        module_eval <<-EOE, __FILE__, __LINE__
          def #{method}(path, request_headers = {}, body = nil, status = 200, response_headers = {})
            @responses.reject! {|r| r[0].path == path && r[0].method == :#{method}}
            @responses << [Request.new(:#{method}, path, nil, request_headers), Response.new(body || "", status, response_headers)]
          end
        EOE
      end 
    end
  end
end

module ActiveResource
  class Connection #:nodoc:
    
    class << self
      attr_reader :request_log

      def log_request(method, path, headers, response)
        @request_log ||= []
        @request_log << {
          :method   => method,
          :path     => path,
          :headers  => headers,
          :response => response
        }
      end

      def flush_request_log
        @request_log = []
      end
      
      def print_request_log
        @request_log ||= []
        if @request_log.empty?
          puts("\n  -----No request attempts logged for this scenario")  
          return
        end
        puts "\n    Request attempts logged for this scenario:\n    --------------------------------------------\n\n"
        @request_log.each do |request|
          puts "    Request: #{request[:method].upcase} #{request[:path]}"
          puts "    Headers: #{request[:headers].inspect}"
          puts "    Response Body:\n#{request[:response].body.split("\n").map {|s| (" "*6) + s}.join("\n")}"
          puts "    Response Code: #{request[:response].code}"
          puts "    Response Headers: #{request[:response].headers}"
          puts "    Response Message: #{request[:response].message}"
          puts "\n\n"
        end
      end
    end
    
    # Execute a GET request.
    # Used to get (find) resources.
    def get(path, headers = {})
      response = request(:get, path, build_request_headers(headers, :get))
      ActiveResource::Connection.log_request(:get, path, build_request_headers(headers, :get), response)
      format.decode(response.body)
    end

    # Execute a DELETE request (see HTTP protocol documentation if unfamiliar).
    # Used to delete resources.
    def delete(path, headers = {})
      response = request(:delete, path, build_request_headers(headers, :delete))
      ActiveResource::Connection.log_request(:delete, path, build_request_headers(headers, :delete), response)
      response
    end

    # Execute a PUT request (see HTTP protocol documentation if unfamiliar).
    # Used to update resources.
    def put(path, body = '', headers = {})
      response = request(:put, path, body.to_s, build_request_headers(headers, :put))
      ActiveResource::Connection.log_request(:put, path, build_request_headers(headers, :put), response)
      response
    end

    # Execute a POST request.
    # Used to create new resources.
    def post(path, body = '', headers = {})
      response = request(:post, path, body.to_s, build_request_headers(headers, :post))
      ActiveResource::Connection.log_request(:post, path, build_request_headers(headers, :post), response) 
      response
    end

    # Execute a HEAD request.
    # Used to obtain meta-information about resources, such as whether they exist and their size (via response headers).
    def head(path, headers = {})
      response = request(:head, path, build_request_headers(headers))
      ActiveResource::Connection.log_request(:head, path, build_request_headers(headers), response)
      response
    end
  end
end
