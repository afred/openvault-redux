config = YAML::load(File.open("#{Rails.root}/config/fedora.yml"))

Rubydora.repository = Rubydora.connect(:url => config[Rails.env]['url'], :user => config[Rails.env]['user'], :password => config[Rails.env]['pass'], :timeout => 1200)

Rubydora.repository.extend Rubydora::Soap

require 'rubydora/ext/solr'
Rubydora::Ext::Solr.load

require 'rubydora/ext/model_loader'
Rubydora::Ext::ModelLoader.load :base_namespace => Openvault::DigitalObjects 

Rubydora::Ext::ModelLoader.load :class => Rubydora::Datastream, :method => :dsid, :base_namespace => Openvault::Datastreams

Blacklight.config[:collection_titles] = Hash[*Rubydora.repository.sparql("SELECT ?pid ?title FROM <#ri> WHERE { ?subject <fedora-rels-ext:isMemberOfCollection> ?pid . OPTIONAL { ?pid <dc:title> ?title } }").map { |x| [x['pid'], (x['title'] unless x['title'] == "null") || false ] }.flatten]

Blacklight.config[:collection_prefix_map] = { 
  'info:fedora/org.wgbh.mla:vietnam' => 'vietnam',
                                 'info:fedora/org.wgbh.mla:sbro' => 'sbro',
                                 'info:fedora/org.wgbh.mla:ntw' => 'ntw',
                                 'info:fedora/org.wgbh.mla:tocn' => 'tocn',
                                 'info:fedora/org.wgbh.mla:pledge' => 'radio',
                                 'info:fedora/org.wgbh.mla:from_the_vault' => 'vault',
                                 'info:fedora/org.wgbh.mla:wpna' => 'wpna',
                                 'info:fedora/umb:collection-id-11' => 'sully',
                                 'info:fedora/org.wgbh.mla:27afb5495dec3586bbcb00e19f6c2841745a248d' => 
'march'
       }

