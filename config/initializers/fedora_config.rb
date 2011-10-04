config = YAML::load(File.open("#{Rails.root}/config/fedora.yml"))

Rubydora.repository = Rubydora.connect(:url => config[Rails.env]['url'], :user => config[Rails.env]['user'], :password => config[Rails.env]['pass'], :timeout => 1200)

Rubydora.repository.extend Rubydora::Soap

require 'rubydora/ext/solr'
Rubydora::Ext::Solr.load

require 'rubydora/ext/model_loader'
Rubydora::Ext::ModelLoader.load :base_namespace => Openvault::DigitalObjects 

Rubydora::Ext::ModelLoader.load :class => Rubydora::Datastream, :method => :dsid, :base_namespace => Openvault::Datastreams

if defined?(Rails::Server)
Blacklight.config[:collection_titles] = Hash[*Rubydora.repository.sparql("SELECT ?pid ?title FROM <#ri> WHERE { ?subject <fedora-rels-ext:isMemberOfCollection> ?pid . OPTIONAL { ?pid <dc:title> ?title } }").map { |x| [x['pid'], (x['title'] unless x['title'] == "null") || false ] }.flatten]
end
