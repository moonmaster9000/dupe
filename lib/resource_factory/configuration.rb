class ResourceFactory 
  class Configuration #:nodoc:
    attr_reader :config
    
    def initialize
      @config ||= {}
      @config[:record_identifiers] = [:id]
    end

    def method_missing(method_name, *args, &block)
      set_config_option(method_name.to_sym, args)
    end


    private
    def set_config_option(key, value)
      @config[key] = value
    end
  end
end


