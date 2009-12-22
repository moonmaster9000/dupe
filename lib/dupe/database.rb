class Dupe
  class Database
    attr_reader :tables
    
    def initialize
      @tables = Hashie::Mash.new
    end
    
    def insert(record)
      if !record.kind_of?(Dupe::Database::Record) || !record.__model__
        raise ArgumentError, "You may only insert well-defined Dupe::Database::Record objects" 
      end
      @tables[record.__model__.name] ||= Hashie::Mash.new
      @tables[record.__model__.name][record.id] = record
    end
  end
end