config = YAML::load(File.open("#{RAILS_ROOT}/config/fedora.yml"))

Rubydora.repository = Rubydora.connect({:url => config[RAILS_ENV]['url'], :user => config[RAILS_ENV]['user'], :password => config[RAILS_ENV]['pass']})

require 'rubydora/rest_api_client/v33'
Rubydora.repository.extend Rubydora::RestApiClient::V33     

require 'rubydora/ext/solr'
Rubydora::Ext::Solr.load

require 'rubydora/ext/model_loader'
Rubydora::Ext::ModelLoader.load :base_namespace => Openvault::DigitalObjects 
Rubydora::Ext::ModelLoader.load :class => Rubydora::Datastream, :method => :dsid, :base_namespace => Openvault::Datastreams

Rubydora::DigitalObject.use_extension(Openvault::DigitalObjects::Surrogate)
