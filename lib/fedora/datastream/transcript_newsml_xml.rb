module Fedora::Datastream
   class TranscriptNewsmlXml < Generic
     def initialize name, opts={}, source=nil, content_type='text/plain'
       @opts = {:controlGroup => 'M', :dsLabel => name, :checksumType => 'DISABLED'}.merge opts
       @source = source
       @name = name
       @content_type = content_type
     end

     def to_solr sum
       newsml = Nokogiri::XML(self.content)
       doc = []
       xmlns = { 'newsml' => 'http://iptc.org/std/nar/2006-10-01/' }

       doc << ["fulltext_t", newsml.xpath('//newsml:partMeta', xmlns).map { |x| x.text }.join("\n")]

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

