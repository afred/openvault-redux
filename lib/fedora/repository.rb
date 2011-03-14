require 'lib/openvault/Fedora-API-M-WSDLDriver.rb'
module Fedora
  class Repository
    def initialize args
      @user = args[:user]
      @pass = args[:pass]
      @endpoint = args[:private_url]
      @public_url = args[:public_url]
    end

    def url args
      return @endpoint unless args[:private] == true
      @public_url 
    end

    def object_url args
      "#{url(args)}/get/#{args[:pid]}/#{args[:datastream]}"
    end

    def client pid=''
      RestClient::Resource.new @endpoint + "/objects/" + pid, :user => @user, :password => @pass
    end

    def soap
      fedora = FedoraAPIM.new(@endpoint + "/services/management")
      fedora.options['protocol.http.basic_auth'] << [@endpoint + "/services/management", @user, @pass]
      fedora
    end

    def risearch options
      RestClient.post @endpoint + "/risearch", options
    end

    def sparql query
      rels_ext = risearch :dt => 'on', :format => 'CSV', :lang => 'sparql', :limit => nil, :query => query, :type => 'tuples'
      FasterCSV.parse(rels_ext.body)
    end

    def fedora_parts pid
         sparql 'PREFIX fedora-model: <info:fedora/fedora-system:def/model#>
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
end
