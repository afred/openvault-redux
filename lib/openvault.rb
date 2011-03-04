module Openvault
  class << self
    attr_accessor :fedora, :fedora_config
  end
  
  @fedora_config ||= {}
  
  def self.init
    
    fedora_config = YAML::load(File.open("#{RAILS_ROOT}/config/fedora.yml"))
    raise "The #{RAILS_ENV} environment settings were not found in the fedora.yml config" unless fedora_config[RAILS_ENV]
    
    Openvault.fedora_config[:url] = fedora_config[RAILS_ENV]['url']
    Openvault.fedora_config[:public_url] = fedora_config[RAILS_ENV]['public_url']  
    Openvault.fedora_config[:public_url] ||= Openvault.fedora_config[:url] 
    Openvault.fedora_config[:private_url] = fedora_config[RAILS_ENV]['private_url']  
    Openvault.fedora_config[:private_url] ||= Openvault.fedora_config[:url] 
  end

  class PermissionDenied < Exception; end

end
