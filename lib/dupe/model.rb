class Dupe
  class Model
    attr_reader :schema
    attr_reader :name
    
    def initialize(name)
      @schema = Dupe::Model::Schema.new
      @name   = name.to_sym
    end
  end
end