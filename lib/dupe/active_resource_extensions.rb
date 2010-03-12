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
        resource_hash = Hash.from_xml(body)
        resource_hash = resource_hash[resource_hash.keys.first]
        resource_hash = {} unless resource_hash.kind_of?(Hash)
        begin
          mocked_response, new_path = Dupe.network.request(:post, path, resource_hash)
          error = false
        rescue Dupe::UnprocessableEntity => e
          mocked_response = {:error => e.message.to_s}.to_xml(:root => 'errors')
          error = true
        end
        ActiveResource::HttpMock.respond_to do |mock|
          if error
            mock.post(path, {}, mocked_response, 422, "Content-Type" => 'application/xml')
          else
            mock.post(path, {}, mocked_response, 201, "Location" => new_path)
          end
        end
        response = request(:post, path, body.to_s, build_request_headers(headers, :post))
        ActiveResource::HttpMock.delete_mock(:post, path)
      end
      response
    end
  end
end
