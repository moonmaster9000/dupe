ActiveResource::HttpMock.instance_eval do #:nodoc:
  def delete_mock(http_method, path) #:nodoc:
    responses.reject! {|r| r[0].path == path && r[0].method == http_method}
  end
end

module ActiveResource #:nodoc:
  class Connection #:nodoc:
    def get(path, headers = {}) #:nodoc:
      begin
        response = request(:get, path, build_request_headers(headers, :get))

      # if the request threw an exception
      rescue
        mocked_response = Dupe.network.request(:get, path)
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get(path, {}, mocked_response)
        end
        response = request(:get, path, build_request_headers(headers, :get))
        ActiveResource::HttpMock.delete_mock(:get, path)
      end
      format.decode(response.body)
    end
    
    def post(path, body = '', headers = {}) #:nodoc:
      begin
        response = request(:post, path, body.to_s, build_request_headers(headers, :post))
        
      # if the request threw an exception
      rescue
        mocked_response = Dupe.network.request(:post, path, body)
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post(path, {}, mocked_response, 201, "Location" => path )
        end
        response = request(:post, path, body.to_s, build_request_headers(headers, :post))
        ActiveResource::HttpMock.delete_mock(:post, path)
      end
      response
    end
    
    def put(path, body = '', headers = {})
      begin
        response = request(:put, path, body.to_s, build_request_headers(headers, :put))
        
      # if the request threw an exception
      rescue
        mocked_response = Dupe.network.request(:put, path)
        ActiveResource::HttpMock.respond_to do |mock|
          mock.put(path, {}, mocked_response)
        end
        response = request(:post, path, body.to_s, build_request_headers(headers, :post))
        ActiveResource::HttpMock.delete_mock(:post, path)
      end
      response
    end
    
    def delete(path, headers = {})
      begin
        response = request(:delete, path, build_request_headers(headers, :delete))
        
      # if the request threw an exception
      rescue
        mocked_response = Dupe.network.request(:delete, path)
        ActiveResource::HttpMock.respond_to do |mock|
          mock.delete(path, {}, mocked_response)
        end
        response = request(:delete, path, build_request_headers(headers, :delete))
        ActiveResource::HttpMock.delete_mock(:delete, path)
      end
      response
    end
    
  end
end
