class Dupe
  class Record #:nodoc:
    def initialize(hash)
      @attributes = hash.merge(hash) {|k,v| v.is_a?(Hash) ? Record.new(v) : v}
    end

    def method_missing(method_name, *args, &block)
      @attributes[method_name.to_sym]
    end
  end
end
