class Dupe
  class Model #:nodoc:
    class Schema #:nodoc:
      # This class represents an attribute template.
      # An attribute template consists of an attribute name (a symbol),
      # a potential default value (nil if not specified), 
      # and a potential transformer proc. 
      class AttributeTemplate #:nodoc:
        
        class NilValue; end
        
        attr_reader :name
        attr_reader :transformer
        attr_reader :default
        
        def initialize(name, options={})
          default = options[:default]
          transformer = options[:transformer]
          
          if transformer
            raise ArgumentError, "Your transformer must be a kind of proc." if !transformer.kind_of?(Proc)
            raise ArgumentError, "Your transformer must accept a parameter." if transformer.arity != 1
          end
          
          @name = name
          @default = default
          @transformer = transformer
        end
        
        # Suppose we have the following attribute template:
        #
        #   console> a = Dupe::Model::Schema::AttributeTemplate.new(:title)
        #   
        # If we call generate with no parameter, we'll get back the following:
        #  
        #   console> a.generate
        #     ===> :title, nil
        #
        # If we call generate with a parameter, we'll get back the following:
        # 
        #   console> a.generate 'my value'
        #     ===> :title, 'my value'
        #
        # If we setup an attribute template with a transformer:
        #   
        #   console> a = 
        #             Dupe::Model::Schema::AttributeTemplate.new(
        #               :title, 
        #               :default => 'default value', 
        #               :transformer => proc {|dont_care| 'test'}
        #             )
        # Then we'll get back the following when we call generate:
        #
        #   console> a.generate
        #     ===> :title, 'default value'
        #
        #   console> a.generate 'my value'
        #     ===> :title, 'test'
        def generate(value=NilValue)
          if value == NilValue
            v = @default.respond_to?(:call) ? @default.call : (@default.dup rescue @default)
          else
            v = (@transformer ? @transformer.call(value) : value)
          end
          
          return @name, v
        end
      end
    end
  end
end
