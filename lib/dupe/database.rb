class Dupe
  class Database #:nodoc:
    attr_reader :tables
    
    #:nodoc:
    class TableDoesNotExistError < StandardError; end
    
    #:nodoc:
    class InvalidQueryError < StandardError; end
    
    # by default, there are not tables in the database
    def initialize
      @tables = {}
    end
    
    # pass in a Dupe::Database::Record object, and this method will store the record
    # in the appropriate table
    def insert(record)
      if !record.kind_of?(Dupe::Database::Record) || !record.__model__ || !record[:id]
        raise ArgumentError, "You may only insert well-defined Dupe::Database::Record objects" 
      end
      @tables[record.__model__.name] ||= []
      @tables[record.__model__.name] << record
      record.__model__.run_after_create_callbacks(record)
    end
    
    def delete(model_name, conditions=nil)
      raise TableDoesNotExistError, "The table ':#{model_name}' does not exist." unless @tables[model_name]
      raise(
        InvalidQueryError, 
        "There was a problem with your select conditions. Please consult the API."
      ) if conditions and (!conditions.kind_of?(Proc) || conditions.arity != 1)
      if !conditions
        @tables.delete(model_name)
        return true
      else
        @tables[model_name].delete_if {|r| conditions.call(r)}
        return true
      end 
    end
    
    # pass in a model_name (e.g., :book) and optionally a proc with 
    # conditions (e.g., {|b| b.genre == 'Science Fiction'})
    # and recieve a (possibly empty) array of results
    def select(model_name, conditions=nil)
      raise TableDoesNotExistError, "The table ':#{model_name}' does not exist." unless @tables[model_name]
      raise(
        InvalidQueryError, 
        "There was a problem with your select conditions. Please consult the API."
      ) if conditions and (!conditions.kind_of?(Proc) || conditions.arity != 1)
      
      return @tables[model_name] if !conditions
      @tables[model_name].select {|r| conditions.call(r)}
    end
    
    def create_table(model_name)
      @tables[model_name.to_sym] ||= []
    end
    
    def truncate_tables
      @tables.each do |table_name, table_records|
        @tables[table_name] = []
      end
    end
    
  end
end