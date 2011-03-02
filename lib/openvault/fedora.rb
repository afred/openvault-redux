require 'lib/openvault/Fedora-API-M-WSDLDriver.rb'

class FedoraRepo
	def self.fedora_user
	  'fedoraAdmin'
	end
	def self.fedora_pass
	  'fedora'
	end
	def self.fedora_rest_uri
	  #'http://localhost:8180/fedora'
          Openvault.fedora_config[:private_url]
	end
	def self.base_url
	  'http://openvault.wgbh.org/media'
	end
	def self.fedora_client pid=''
          RestClient::Resource.new FedoraRepo.fedora_rest_uri + "/objects/" + pid, :user => FedoraRepo.fedora_user, :password => FedoraRepo.fedora_pass
	end
	def self.soap
          fedora = FedoraAPIM.new(FedoraRepo.fedora_rest_uri + "/services/management")
	  fedora.options['protocol.http.basic_auth'] << [FedoraRepo.fedora_rest_uri + "/services/management", FedoraRepo.fedora_user, FedoraRepo.fedora_pass]
	  fedora
	end

        def self.relsext query
          rels_ext = RestClient.post FedoraRepo.fedora_rest_uri + "/risearch", :dt => 'on', :format => 'CSV', :lang => 'sparql', :limit => nil, :query => query, :type => 'tuples'
          FasterCSV.parse(rels_ext.body)
        end

        def self.fedora_parts pid
          FedoraRepo.relsext 'PREFIX fedora-model: <info:fedora/fedora-system:def/model#>
          PREFIX dc: <http://purl.org/dc/elements/1.1/>
          PREFIX fedora-rels-ext: <info:fedora/fedora-system:def/relations-external#>
          SELECT ?pid
          WHERE {
              {
                { ?pid fedora-rels-ext:isPartOf <info:fedora/' + pid + '> } UNION
              { <info:fedora/' + pid + '>  fedora-rels-ext:hasPart ?pid }
            }
          }'
        end
end
