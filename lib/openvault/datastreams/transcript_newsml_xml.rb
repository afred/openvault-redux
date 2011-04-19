module Openvault::Datastreams
   module TranscriptNewsmlXml
     def to_solr solr_doc
       super(solr_doc)
       newsml = Nokogiri::XML(self.content)
       doc = []
       xmlns = { 'newsml' => 'http://iptc.org/std/nar/2006-10-01/' }

       doc << ["fulltext_t", newsml.xpath('//newsml:partMeta', xmlns).map { |x| x.text }.join("\n")]

       doc.each do |key,value|
         key.gsub!('__', '_')
         solr_doc[key] ||= []
         solr_doc[key] <<  value.strip
       end
     end
   end
end

