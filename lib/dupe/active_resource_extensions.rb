ActiveResource::HttpMock.instance_eval do #:nodoc:
  def delete_mock(http_method, path) #:nodoc:
    responses.reject! {|r| r[0].path == path && r[0].method == http_method}
  end
end

module ActiveResource #:nodoc:
  class Connection #:nodoc:
    def get(path, headers = {}) #:nodoc:
      begin
        response = request(:get, path, build_request_headers(headers, :get, self.site.merge(path)))

      # if the request threw an exception
      rescue ActiveResource::InvalidRequestError
        mocked_response = Dupe.network.request(:get, path)
        ActiveResource::HttpMock.respond_to(false) do |mock|
          mock.get(path, headers, mocked_response)
        end
        begin
          response = request(:get, path, build_request_headers(headers, :get, self.site.merge(path)))
        ensure
          ActiveResource::HttpMock.delete_mock(:get, path)
        end
      end

      if ActiveResource::VERSION::MAJOR == 3 && ActiveResource::VERSION::MINOR >= 1
        response
      else
        Dupe.format.decode(response.body)
      end
    end

    def post(path, body = '', headers = {}) #:nodoc:
      begin
        response = request(:post, path, body.to_s, build_request_headers(headers, :post, self.site.merge(path)))

      # if the request threw an exception
      rescue ActiveResource::InvalidRequestError
        unless body.blank?
          resource_hash = Dupe.format.decode(body)
        end
        resource_hash = {} unless resource_hash.kind_of?(Hash)
        begin
          mocked_response, new_path = Dupe.network.request(:post, path, resource_hash)
          error = false
        rescue Dupe::UnprocessableEntity => e
          mocked_response =
            case Dupe.format
            when ActiveResource::Formats::JsonFormat
              Dupe.format.encode( {errors: e.errors}, :root => 'errors')
            else
              Dupe.format.encode( {error: e.errors}, :root => 'errors')
            end

          error = true
        end
        ActiveResource::HttpMock.respond_to(false) do |mock|
          if error
            mock.post(path, headers, mocked_response, 422, "Content-Type" => Dupe.format.mime_type)
          else
            mock.post(path, headers, mocked_response, 201, "Location" => new_path)
          end
        end
        begin
          response = request(:post, path, body.to_s, build_request_headers(headers, :post, self.site.merge(path)))
        ensure
          ActiveResource::HttpMock.delete_mock(:post, path)
        end
      end
      response
    end

    def put(path, body = '', headers = {}) #:nodoc:
      begin
        response = request(:put, path, body.to_s, build_request_headers(headers, :put, self.site.merge(path)))

      # if the request threw an exception
      rescue ActiveResource::InvalidRequestError
        unless body.blank?
          resource_hash = Dupe.format.decode(body)
        end
        resource_hash = {} unless resource_hash.kind_of?(Hash)
        resource_hash.symbolize_keys!

        begin
          error = false
          mocked_response, path = Dupe.network.request(:put, path, resource_hash)
        rescue Dupe::UnprocessableEntity => e
          mocked_response =
            case Dupe.format
            when ActiveResource::Formats::JsonFormat
              Dupe.format.encode( {errors: e.errors}, :root => 'errors')
            else
              Dupe.format.encode( {error: e.errors}, :root => 'errors')
            end
          error = true
        end
        ActiveResource::HttpMock.respond_to(false) do |mock|
          if error
            mock.put(path, headers, mocked_response, 422, "Content-Type" => Dupe.format.mime_type)
          else
            mock.put(path, headers, mocked_response, 204)
          end
        end
        begin
          response = request(:put, path, body.to_s, build_request_headers(headers, :put, self.site.merge(path)))
        ensure
          ActiveResource::HttpMock.delete_mock(:put, path)
        end
      end
      response
    end

    def delete(path, headers = {})
      begin
        response = request(:delete, path, build_request_headers(headers, :delete, self.site.merge(path)))
      rescue ActiveResource::InvalidRequestError
        Dupe.network.request(:delete, path)

        ActiveResource::HttpMock.respond_to(false) do |mock|
          mock.delete(path, headers, nil, 200)
        end
        begin
          response = request(:delete, path, build_request_headers(headers, :delete, self.site.merge(path)))
        ensure
          ActiveResource::HttpMock.delete_mock(:delete, path)
        end
      end
      response
    end
  end
end
