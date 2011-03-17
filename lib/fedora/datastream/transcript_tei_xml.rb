module Fedora::Datastream
   class TranscriptTeiXml < Generic
     def initialize name, opts={}, source=nil, content_type='text/plain'
       @opts = {:controlGroup => 'M', :dsLabel => name, :checksumType => 'DISABLED'}.merge opts
       @source = source
       @name = name
       @content_type = content_type
     end

     def to_solr sum
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



       doc.inject({}) do |sum, (key,value)|
         next sum if value.blank?
         key.gsub!('__', '_')
         sum[key] ||= []
         sum[key] <<  value.strip

         sum
       end
     end
   end
end

