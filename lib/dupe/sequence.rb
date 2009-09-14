class Dupe
  class Sequence  #:nodoc:
    def initialize(start=0)
      @sequence_value = start
    end

    def next
      @sequence_value += 1
    end
  end
end
