class Dupe
  class Database
    class Record < Hash
      attr_accessor :__model__
      
      def id
        self[:id]
      end
      
      def id=(value)
        self[:id] = value
      end
      
      def method_missing(method_name, *args, &block)
        if attempting_to_assign(method_name)
          method_name = method_name.to_s[0..-2].to_sym
          self[method_name] = args.first
        else
          self[method_name.to_sym]
        end
      end
      
      private
      def attempting_to_assign(method_name)
        method_name.to_s[-1..-1] == '=' 
      end
    end
  end
end