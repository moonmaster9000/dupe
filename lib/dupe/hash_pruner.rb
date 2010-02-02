class HashPruner
  class << self
    def prune(hash)
      HashPruner.new.prune hash
    end
  end
 
  def initialize()
    @visited = {}
  end
 
  def prune(item)
    if item.kind_of? Array
      item.map {|i| prune(i)}.reject {|v| v==nil}
    elsif item.kind_of? Hash
      if @visited[item.object_id]
        nil
      else
        @visited[item.object_id] = true
        {}.tap do |new_hash|
          item.each do |k,v|
            new_hash[k] = prune(v)
          end
        end
      end
    else
      item
    end
  end
end

class Hash 
  def to_xml_safe(options={})
    HashPruner.prune(self).to_xml(options)  
  end
end
