class Dupe
  class Database
    attr_reader :tables
    
    class TableDoesNotExistError < StandardError; end
    class InvalidQueryError < StandardError; end
    
    def initialize
      @tables = {}
    end
    
    def insert(record)
      if !record.kind_of?(Dupe::Database::Record) || !record.__model__
        raise ArgumentError, "You may only insert well-defined Dupe::Database::Record objects" 
      end
      @tables[record.__model__.name] ||= {}
      @tables[record.__model__.name][record.id] = record
    end
        
    def select(model_name, conditions=nil)
      raise TableDoesNotExistError, "The table ':#{model_name}' does not exist." unless @tables[model_name]
      raise(
        InvalidQueryError, 
        "There was a problem with your select conditions. Please consult the API."
      ) if conditions and (!conditions.kind_of?(Proc) || conditions.arity != 1)
      
      return @tables[model_name].values if !conditions
      @tables[model_name].values.select {|r| conditions.call(r)}
    end
    
    def create_table(model_name)
      @tables[model_name.to_sym] ||= {}
    end
  end
end