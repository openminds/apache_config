module Apache
  autoload :Node,           'apache_config/node'
  autoload :VirtualHost,    'apache_config/virtual_host'
  autoload :WriteBackArray, 'apache_config/write_back_array'
  
  class Config
    TabSize     = "    "
    Comment     = /^\s*#\s?(.*?)\s*$/
    Blank       = /^\s+$/
    Directive   = /^\s*(\w+)(?:\s+(.*?)|)$/
    SectionOpen = /^\s*<\s*(\w+)(?:\s+([^>]+)|\s*)>$/
    SectionClose = /^\s*<\/\s*(\w+)\s*>$/

    def initialize(path)
      @path = path
      @config = parse_config(path)
    end
    
    def virtual_hosts
      @config.children.map { |vh| VirtualHost.new(vh) }
    end

    def to_config(root = nil, indent = "")
      element = root || @config
      content = ""

      case
        when element.isRoot?
          element.children.map { |c| to_config(c) }.join
        when element.hasChildren?
          "#{indent}<#{element.name} #{element.content}>\n" +
          element.children.map {|c| to_config(c, indent + TabSize) }.join +
          "#{indent}</#{element.name}>\n"
        when element.name == :comment
          "#{indent}# #{element.content}\n"
        when element.name == :blank
          "#{indent}\n"
        else
          "#{indent}#{element.name} #{element.content}\n"
        end
    end

    private
    def parse_config(path)
      current_child = Node.new("ROOT")

      File.open(path).read.split(/\n/).each do |line|
        case line
        when Comment
          current_child << Node.new(:comment, $1)
        when Blank
          current_child << Node.new(:blank)
        when Directive
          current_child << Node.new($1, $2)
        when SectionOpen
          current_child = current_child << Node.new($1, $2)
        when SectionClose
          current_child = current_child.parent
        end
      end

      current_child
    end
  end
end