class Dupe
  class Model #:nodoc:
    attr_reader :schema
    attr_reader :name
    attr_reader :id_sequence
    
    def initialize(name)
      @schema = Dupe::Model::Schema.new
      @name   = name.to_sym
      @id_sequence = Sequence.new
    end
    
    def define(definition_proc)
      definition_proc.call @schema
    end
    
    def create(attributes={})
      Database::Record.new.tap do |record|
        record.__model__ = self
        record.id = @id_sequence.next
        record.merge! default_record
        record.merge! transform(attributes)
      end
    end
    
    # called by the Dupe::Database#insert method
    def run_after_create_callbacks(record)
      @schema.after_create_callbacks.each do |callback|
        callback.call record
      end
    end
    
    private
    def default_record
      Database::Record.new.tap do |record|
        # setup all the required attributes
        @schema.attribute_templates.each do |attribute_template_name, attribute_template|
          required_attribute_name, required_attribute_value = 
            attribute_template.generate
          record[required_attribute_name] = required_attribute_value
        end
      end
    end
    
    def transform(attributes)
      Database::Record.new.tap do |record|
        # override the required attributes or create new attributes
        attributes.each do |attribute_name, attribute_value|
          if @schema.attribute_templates[attribute_name]
            k, v = @schema.attribute_templates[attribute_name].generate attribute_value
            record[attribute_name] = v
          else
            record[attribute_name] = attribute_value
          end
        end
      end
    end
  end
end