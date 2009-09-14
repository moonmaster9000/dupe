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

