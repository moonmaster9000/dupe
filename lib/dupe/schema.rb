class Dupe
  class Model #:nodoc:
    class Schema #:nodoc:
      attr_reader :attribute_templates
      attr_reader :after_create_callbacks
      
      def initialize
        @attribute_templates = {}
        @after_create_callbacks = []
      end
      
      def method_missing(method_name, *args, &block)
        attribute_name = method_name.to_s[-1..-1] == '=' ? method_name.to_s[0..-2].to_sym : method_name
        if block && block.arity < 1
          default_value = block
          transformer = nil
        else
          default_value = args[0]
          transformer = block
        end
        
        @attribute_templates[method_name.to_sym] = 
          AttributeTemplate.new method_name.to_sym, :default => default_value, :transformer => transformer
      end
      
      def after_create(&block)
        raise(
          ArgumentError, 
          "You must pass a block that accepts a single parameter to 'after_create'"
        ) if !block || block.arity != 1
        
        @after_create_callbacks << block
      end

      def uniquify(*args)
        raise ArgumentError, "You must pass at least one attribute to uniquify." if args.empty?
        raise ArgumentError, "You may only pass symbols to uniquify." unless all_members_of_class(args, Symbol)

        args.each do |attribute|
          after_create do |record|
            record[attribute] = "#{record.__model__.name} #{record.id} #{attribute}" unless record[attribute]
          end
        end
      end

      private
      def all_members_of_class(ary, klass)
        ary.inject(true) {|bool, v| bool && v.kind_of?(klass)}
      end
    end
  end
end
