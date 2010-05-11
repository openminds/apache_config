require "test/unit"
require 'rubygems'
require 'fakefs'

require "apache_config"

class TestApacheConfig < Test::Unit::TestCase
  Config =<<APACHE
<VirtualHost *>
    ServerName example.com
    ServerAlias www.example.com
    Documentroot /var/www/default/public
    Errorlog /var/log/apache2/default.errorlog
    LogLevel Warn
    CustomLog /var/log/apache2/default.customlog combined
    
    <Directory "/var/www/default/public">
        Options Indexes Includes FollowSymLinks IncludesNOEXEC
        AllowOverride AuthConfig FileInfo Indexes Options Limit
        Order allow,deny
        Allow from all
        # Foo
    </Directory>
</VirtualHost>
APACHE

  def setup
    File.open('/etc/apache2/example.conf', 'w') do |f|
      f.write Config 
    end
  end
  
  # Quite the integration test you have here..
  def test_apache_parsed_config_outputs_the_same
    config = Apache::Config.new('/etc/apache2/example.conf')
    assert_equal Config, config.to_config
  end
  
  def test_adding_to_virtual_hosts
    config = Apache::Config.new('/etc/apache2/example.conf')
    config.virtual_hosts.first.aliases << 'foo.be'
    
    assert_match "ServerAlias www.example.com foo.be", config.to_config
  end
end