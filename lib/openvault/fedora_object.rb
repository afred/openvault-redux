module Openvault::FedoraObject
  def client
    FedoraRepo.fedora_client(pid)
  end
  def pid
    get('pid_s')
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
    url = Openvault.fedora_config[:public_url]
    url = Openvault.fedora_config[:private_url] if options[:private] == true
    "#{url}/get/#{pid}/#{datastream}"
  end

  def datastream datastream, options = {}
    instance_variable_get datastream if instance_variable_defined? datastream
    instance_variable_set datastream, client["datastreams/#{datastream}/content"].get
  end
end
