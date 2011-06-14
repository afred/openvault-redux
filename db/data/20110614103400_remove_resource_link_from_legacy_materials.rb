class RemoveResourceLinkFromLegacyMaterials < ActiveRecord::Migration
  def self.up
    require 'cgi'
    xmlns = { 'dc' => 'http://purl.org/dc/elements/1.1/' }
    objs = Rubydora.repository.find_by_sparql('
SELECT ?pid FROM <#ri> WHERE {
  ?pid <http://purl.org/dc/elements/1.1/description> ?description .
  FILTER(regex(str(?description), "resource_link"))
}') 

    objs.each do |obj|
      doc = Nokogiri::XML(obj.datastream['DC'].content) rescue nil

      doc.xpath('//dc:description', xmlns).each do |el|
        d = Nokogiri::HTML(el.text)
        d.xpath('//resource_link').each(&:remove)
        el.inner_html = CGI::escapeHTML(d.xpath('//p').inner_html)
      end

      obj.datastream['DC'].content = doc.to_s 
      obj.datastream['DC'].save 
    end

  end

  def self.down

  end
end
