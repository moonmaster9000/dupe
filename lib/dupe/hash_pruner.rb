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
        item.dup.delete_if {|k,v| v.kind_of?(Hash) || v.kind_of?(Array)}
      else
        @visited[item.object_id] = true
        new_hash = {}
        item.each do |k,v|
          new_hash[k] = prune(v)
        end
        @visited.delete item.object_id
        new_hash
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
