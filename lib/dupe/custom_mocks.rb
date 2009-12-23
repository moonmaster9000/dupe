module CustomMocks
  class NotImplementedError < StandardError
  end
  
  def get_request(url)
    raise NotImplementedError.new("you must implement the CustomMocks::custom_service method.")
  end
end