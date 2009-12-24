class Dupe
  class Network
    class UnknownRestVerbError < StandardError; end
    VERBS = [:get, :post, :put, :delete]
    
    module RestValidation  
      def validate_request_type(verb)
        raise(
          Dupe::Network::UnknownRestVerbError,
          "Unknown REST verb ':#{verb}'. Valid REST verbs are :get, :post, :put, and :delete."
        ) unless Dupe::Network::VERBS.include?(verb)
      end
    end
  end
end