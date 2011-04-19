module Openvault::Datastreams
   module TranscriptTeiXml
     def to_solr solr_doc = {}
       super(solr_doc)
       tei = Nokogiri::XML(self.content)
       doc = []
       xmlns = { 'tei' => 'http://www.tei-c.org/ns/1.0' }

       doc << ["tei_language_s", tei.xpath('//tei:langUsage/tei:language/@ident', xmlns).first.to_s]

       tei.xpath('//tei:keywords[contains(@scheme,"merlot.org")]/tei:term/text()', xmlns).each do |tag|
         doc << ["merlot_s", tag.text]
       end

       tei.xpath('//tei:body//tei:name', xmlns).each do |tag|
         doc << ["tei_#{tag['type']}_s", tei.xpath("//tei:term[@xml:id='#{tag['ref'].gsub(/^#/, '')}']/text()", xmlns).first.to_s]
       end

       tei.xpath('//tei:spanGrp[@type="topic"]/span', xmlns).each do |tag|
         doc << ["tei_topic_s", tag.text]
       end
       tei.xpath('//tei:spanGrp[@type="title"]/span', xmlns).each do |tag|
         doc << ["tei_title_s", tag.text]
       end

       doc << ["fulltext_t", tei.xpath('//tei:body', xmlns).map { |x| x.text }.join("\n")]



       doc.each do |key,value|
         key.gsub!('__', '_')
         solr_doc[key] ||= []
         solr_doc[key] <<  value.strip
       end
     end
   end
end

