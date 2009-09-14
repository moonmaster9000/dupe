class ResourceFactory 
  class Attribute #:nodoc:
    def initialize(name, value=nil, prock=nil)
      @name, @value, @prock = name.to_sym, value, prock
    end

    def value(v=nil)
      v = @value.dup if @value and !v
      @prock && v ? @prock.call(v) : v 
    end

    def to_hash
      {@name => value} 
    end

  end
end
