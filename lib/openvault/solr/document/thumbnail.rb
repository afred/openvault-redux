module Openvault::Solr::Document::Thumbnail
  def self.extended(document)
    Openvault::Solr::Document::Thumbnail.register_export_formats( document )
  end

  def self.register_export_formats(document)
    document.will_export_as(:jpg, 'image/jpg')
    document.export_formats[:jpg][:thumbnails] = document._thumbnail
  end

  def export_as_jpg
    open(thumbnail.url).read
  end

  def export_as_jpg_with_redirect
    thumbnail.url
  end

  def thumbnail
    @thumbnail ||= _thumbnail
  end

  def _thumbnail document=self
    Openvault::Solr::Document::Thumbnail::Generator.new(document)
  end
end
