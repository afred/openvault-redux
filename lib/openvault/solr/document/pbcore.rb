module Openvault::Solr::Document::Pbcore
  def self.extended(document)
    document.will_export_as(:pbcore, "text/xml+pbcore")
  end
  def to_pbcore
    open(self.fedora_object.datastream_url("PBCore")).read.gsub('<?xml version="1.0" encoding="UTF-8"?>', '')
  end
  def export_as_pbcore
    self.to_pbcore
  end
end
