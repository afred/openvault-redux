class FixSullyTemporalCoverage < ActiveRecord::Migration
  def self.up
    xmlns = { 'pbcore' => 'http://www.pbcore.org/PBCore/PBCoreNamespace.html' }
objs = Rubydora.repository.find_by_sparql '
SELECT ?pid FROM <#ri> WHERE {
  ?pid <info:fedora/fedora-system:def/view#disseminates> ?tds.
  ?tds  <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/PBCore> .
  FILTER(regex(str(?pid), "umb"))
}' 
    objs.each do |obj|
      doc = Nokogiri::XML(obj.datastream['PBCore'].content) rescue nil
      next unless doc
      update_needed = false

      doc.xpath('//pbcore:pbcoreCoverage[pbcore:coverage/text() = "n/d"]', xmlns).each do |x|
        x.remove
        update_needed = true
      end

      obj.datastream['PBCore'].content = doc.to_s if update_needed
      obj.datastream['PBCore'].save if update_needed
    end
  end

  def self.down
  end

end
