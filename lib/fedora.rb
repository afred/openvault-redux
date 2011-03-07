module Fedora
  class << self
    attr_accessor :fedora, :repository_config
  end
  
  @repository_config ||= {}
  
  def self.init
    
    repository_config = YAML::load(File.open("#{RAILS_ROOT}/config/fedora.yml"))
    raise "The #{RAILS_ENV} environment settings were not found in the fedora.yml config" unless repository_config[RAILS_ENV]
    
    Fedora.repository_config[:url] = repository_config[RAILS_ENV]['url']
    Fedora.repository_config[:public_url] = repository_config[RAILS_ENV]['public_url']  
    Fedora.repository_config[:public_url] ||= Fedora.repository_config[:url] 
    Fedora.repository_config[:private_url] = repository_config[RAILS_ENV]['private_url']  
    Fedora.repository_config[:private_url] ||= Fedora.repository_config[:url] 
  end

  def self.repository
    Fedora::Repository.new Fedora.repository_config
  end

  def self.private_repository
    Fedora::Repository.new Fedora.repository_config
  end
end
