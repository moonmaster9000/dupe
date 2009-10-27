class Dupe 
  class Configuration #:nodoc:
    attr_reader :config
    
    def initialize
      @config ||= {}
      @config[:record_identifiers] = [:id]
    end

    def method_missing(method_name, *args, &block)
      set_config_option(method_name.to_sym, method_name.to_s.plural? ? args : args.first)
    end


    private
    def set_config_option(key, value)
      @config[key] = value
    end
  end
end
