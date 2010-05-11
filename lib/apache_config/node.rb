module Apache
  class Node
    attr_accessor :name, :content, :children, :parent
    
    def initialize name, content = nil
      @name, @content = name, content
    end
    
    def [] name
      r = Array(children).select { |child| child.name == name }
      case r.size
      when 0
        self << Node.new(name)
      when 1
        r.first
      else
        r
      end
    end
    
    def << node
      @children ||= []
      @children << node
      node.parent = self
      
      node
    end
    
    def isRoot?
      parent.nil?
    end
    
    def hasChildren?
      children && children.any?
    end
  end
end