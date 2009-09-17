class Dupe
  class Record #:nodoc:
    def initialize(hash)
      @attributes = hash.merge(hash) do |k,v| 
        if v.is_a?(Hash) 
          Record.new(v)
        elsif v.is_a?(Array)
          v.map {|r| Record.new(r)}
        else
          v
        end
      end
    end

    def method_missing(method_name, *args, &block)
      @attributes[method_name.to_sym]
    end
  end
end
