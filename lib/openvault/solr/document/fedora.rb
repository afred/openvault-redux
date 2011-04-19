module Openvault::Solr::Document::Fedora
  def self.extended(document)
  end

  def pid
    get('pid_s')
  end
  
  def fedora_object
    Rubydora.repository.find(pid)
  end
end
