module Openvault::FedoraObject

  def pid
    get('pid_s')
  end
  def datastream_url datastream, options = {}
    url = Openvault.fedora_config[:public_url]
    url = Openvault.fedora_config[:private_url] if options[:private] == true
    "#{url}/get/#{pid}/#{datastream}"
  end
end
