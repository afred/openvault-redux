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
      return @soap if @soap
      require 'soap/wsdlDriver'

      @soap = SOAP::WSDLDriverFactory.new("#{ @endpoint }/services/management?wsdl").create_rpc_driver
      @soap.options['protocol.http.basic_auth'] << [@soap.endpoint_url, @user, @pass]

      @soap
    end

    def risearch options
      RestClient.post @endpoint + "/risearch", options
    end

    def sparql query
      rels_ext = risearch :dt => 'on', :format => 'CSV', :lang => 'sparql', :limit => nil, :query => query, :type => 'tuples'
      FasterCSV.parse(rels_ext.body, :headers => true)
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
