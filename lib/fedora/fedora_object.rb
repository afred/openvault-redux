module Fedora
  class FedoraObject
    def initialize pid, repository = nil
      @repository = repository
      @repository ||= Fedora.repository
      @pid = pid
    end
    
    def pid
      @pid
    end

    def client
      @repository.client(pid)
    end
  
    def profile
      @profile ||= Nokogiri::XML(client['/?format=xml'].get)
      h = {}
      @profile.xpath('/objectProfile/*').map { |tag| h[tag.name] ||= []; h[tag.name] << tag.text }
    end
  
    def datastreams
      @datastreams ||= Nokogiri::XML(client['datastreams?format=xml'].get)
  
      @datasteams.xpath('//datastream/@dsid').map { |ds| ds.to_s }
    end
  
    def datastream_url datastream, options = {}
      url = @repository.object_url(:pid => pid, :datastream => datastream, :private => options[:private])
    end
  
    def datastream datastream, options = {}
      instance_variable_get datastream if instance_variable_defined? datastream
      instance_variable_set datastream, client["datastreams/#{datastream}/content"].get
    end
  end
end
