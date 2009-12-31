class Dupe
  class Network #:nodoc:
    #:nodoc:
    class UnknownRestVerbError < StandardError; end #:nodoc:
    VERBS = [:get, :post, :put, :delete] #:nodoc:
    
    module RestValidation  #:nodoc:
      def validate_request_type(verb)
        raise(
          Dupe::Network::UnknownRestVerbError,
          "Unknown REST verb ':#{verb}'. Valid REST verbs are :get, :post, :put, and :delete."
        ) unless Dupe::Network::VERBS.include?(verb)
      end
    end
  end
end