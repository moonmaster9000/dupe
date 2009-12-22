class Dupe
  class Model
    class Schema 
      attr_reader :attribute_templates
      
      def initialize
        @attribute_templates = {}
      end
      
      def method_missing(method_name, *args, &block)
        attribute_name = method_name.to_s[-1..-1] == '=' ? method_name.to_s[0..-2].to_sym : method_name
        @attribute_templates[method_name.to_sym] = 
          AttributeTemplate.new method_name.to_sym, :default => args[0], :transformer => block
      end
    end
  end
end