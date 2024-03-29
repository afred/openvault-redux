module Openvault::Datastreams
   module Dc
     def to_solr doc = {}
      super(doc)
      return if digital_object.datastreams.keys.include? "DublinCore"
      xml = Nokogiri::XML(content)
      xmlns = {'dc' =>"http://purl.org/dc/elements/1.1/", 'dcterms' =>"http://purl.org/dc/terms/", 'fedora-rels-ext' =>"info:fedora/fedora-system:def/relations-external#", 'oai_dc' =>"http://www.openarchives.org/OAI/2.0/oai_dc/", 'rdf' =>"http://www.w3.org/1999/02/22-rdf-syntax-ns#", 'xsi' =>"http://www.w3.org/2001/XMLSchema-instance"}

      xml.xpath('//dc:*', xmlns).each do |tag|
        case tag.name
          when 'description'
            doc["#{tag.namespace.prefix}_#{tag.name}_t"] ||= []
            doc["#{tag.namespace.prefix}_#{tag.name}_t"] << tag.text
          when 'date'
            doc["dc_date_year_i"] = tag.text.scan(/(\d{4})/).flatten.first
            doc["#{tag.namespace.prefix}_#{tag.name}_s"] ||= []
            doc["#{tag.namespace.prefix}_#{tag.name}_s"] << tag.text
          else
            doc["#{tag.namespace.prefix}_#{tag.name}_s"] ||= []
            doc["#{tag.namespace.prefix}_#{tag.name}_s"] << tag.text
        end
      end

      doc["title_s"] ||= xml.xpath('//dc:title/text()', xmlns).first.text rescue nil
      doc["title_s"] ||= doc["pid_s"]
      doc["slug_s"] ||= doc["title_s"].parameterize.to_s rescue nil
     end
   end
end

