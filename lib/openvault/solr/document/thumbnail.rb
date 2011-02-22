module Openvault::Solr::Document::Thumbnail
  def self.extended(document)
    Openvault::Solr::Document::Thumbnail.register_export_formats( document )
  end

  def self.register_export_formats(document)
    document.will_export_as(:jpg)
  end

  def export_as_jpg

  end

  def thumbnail
    @thumbnail ||= Openvault::Solr::Document::Thumbnail::Generator.new(self)
  end
end
