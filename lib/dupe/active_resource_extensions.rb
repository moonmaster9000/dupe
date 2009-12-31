ActiveResource::HttpMock.instance_eval do #:nodoc:
  def delete_mock(http_method, path)
    responses.reject! {|r| r[0].path == path && r[0].method == http_method}
  end
end

module ActiveResource #:nodoc:
  class Connection #:nodoc:
    def get(path, headers = {})
      begin
        response = request(:get, path, build_request_headers(headers, :get))

      # if the request threw an exception
      rescue
        mocked_response = Dupe.network.request(:get, path)
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get path, {}, mocked_response
        end
        response = request(:get, path, build_request_headers(headers, :get))
        ActiveResource::HttpMock.delete_mock(:get, path)
      end
      format.decode(response.body)
    end
  end
end
