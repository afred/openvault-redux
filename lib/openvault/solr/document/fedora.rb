module Openvault::Solr::Document::Fedora
  def self.extended(document)
  end

  def pid
    get('pid_s')
  end
  
  def fedora_object
    Fedora::FedoraObject.new(pid)
  end
end
