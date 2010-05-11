module Apache
  class WriteBackArray < Array
    def initialize(node, elements)
      super(elements)
      @node = node
    end
    
    def <<(element)
      super
      @node.content = join(' ')
    end
  end
end