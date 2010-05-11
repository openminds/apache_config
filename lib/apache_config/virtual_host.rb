class VirtualHost
  def initialize(config)
    @config = config
  end
  
  def domain
    @config['ServerName'].content
  end
  
  def domain=(dom)
    @config['ServerName'].content = dom
  end
  
  def aliases
    Apache::WriteBackArray.new(@config['ServerAlias'], @config['ServerAlias'].content.to_s.split(/\s+/))
  end
  
  def domains
    [domain] + aliases
  end
  
  def document_root
    @config['Documentroot'].content
  end
end