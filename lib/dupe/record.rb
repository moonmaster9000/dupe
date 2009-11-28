class Dupe
  class Record    
    attr_accessor :internal_attributes_hash
    
    def initialize(hash={})
      @internal_attributes_hash = 
        hash.merge(hash) do |k,v| 
          process_value(v)
        end
    end

    # allows you to access a record like: 
    #   irb> book = Dupe::Record.new :title => 'The Carpet Makers', :author => {:name => 'Andreas Eschbach'}
    #   irb> book.title
    #     ==> 'The Carpet Makers'
    #   irb> book.author.name
    #     ==> 'Andreas Eschbach'
    #   irb> book.genre = 'Science Fiction'
    #   irb> book.genre
    #     ==> 'Science Fiction'
    def method_missing(method_name, *args, &block)
      if method_name.to_s[-1..-1] == '='
        @internal_attributes_hash[method_name.to_s[0..-2].to_sym] = 
          process_value(args[0])
      else
        @internal_attributes_hash[method_name.to_sym]
      end
    end
    
    # allows you to access a record like: 
    #   irb> book = Dupe::Record.new :title => 'The Carpet Makers', :author => {:name => 'Andreas Eschbach'}
    #   irb> book[:title]
    #     ==> 'The Carpet Makers'
    #   irb> book[:author][:name]
    #     ==> 'Andreas Eschbach'
    #   irb> book.genre = 'Science Fiction'
    #   irb> book.genre
    #     ==> 'Science Fiction'
    def [](key)
      @internal_attributes_hash[key.to_sym]
    end
    
    # allows you to set a record like: 
    #   irb> book = Dupe::Record.new :title => 'The Carpet Makers', :author => {:name => 'Andreas Eschbach'}
    #   irb> book[:genre] = 'Science Fiction'
    #   irb> book[:genre]
    #     ==> 'Science Fiction'
    def []=(key, value)
      @internal_attributes_hash[key.to_sym] = process_value(value)
    end
        
    private
    def process_value(v)
      if v.is_a?(Hash) 
        Record.new(v)
      elsif v.is_a?(Array)
        v.map {|r| process_value(r)}
      else
        v
      end
    end
  end
end
