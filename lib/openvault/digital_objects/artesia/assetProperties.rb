module Openvault::DigitalObjects::Artesia
  module Assetproperties
     def self.extended(document)
     end

     def process!
       objects = assetProperties.xpath('//UOIS').map do |uois|
         Rubydora.repository.find("org.wgbh.mla:#{uois['UOI_ID']}").delete rescue nil
         obj = Rubydora.repository.create("org.wgbh.mla:#{uois['UOI_ID']}") 
         
         obj.models << 'info:fedora/artesia:asset'
         obj.models << 'info:fedora/wgbh:CONCEPT'

         obj.member_of << self

         ds = obj['UOIS_XML']
         ds.content = uois.to_s
         ds.mimeType = 'text/xml'
         ds.save

         Rubydora.repository.find(obj.pid)
       end.each do |obj|
         assetProperties_links.select { |x| x[:subject] == obj.pid }.each do |link|
           obj.add_relationship(link[:predicate], "info:fedora/#{link[:object]}")
         end
       end.each do |obj|
         obj.add_metadata_sdef_datastreams!
       end.each do |obj|
         uois = Nokogiri::XML(obj['UOIS_XML'].content)
         name = uois.xpath('//UOIS/@NAME').first.to_s
         files = []
         files = Dir.glob("/Volumes/MLAMellonDigLib3/media/**/#{name}")
         files += Dir.glob("/Volumes/MLAMellonDigLib3/media/**/#{File.basename(name, File.extname(name))}.*")
         files.reject! { |x| x =~ /thumbnails\/.*\// }
         obj.add_media_datastreams!(files.uniq)
       end

       objects.each do |obj|
         # add related files..
         assetProperties_links.select { |x| x[:subject] == obj.pid }.each do |link|
           case link[:predicate].split("#").last
             when "CONTAINS"
               # Transcript
               object = Rubydora.repository.find(link[:object])
               dsid = object.datastreams.keys.select { |x| x =~ /\.xml$/ }.first
               ds = obj[dsid]
               ds.dsLocation = "http://local.fedora.server/fedora/get/#{object.pid}/#{dsid}"
               ds.mimeType = 'text/xml'
               ds.controlGroup = 'E'
               ds.save

             when "PLACEDGR"                     
               object = Rubydora.repository.find(link[:object])
               dsid = object.datastreams.keys.select { |x| x =~ /^Image/ }.first
               ds = obj['Thumbnail']
               ds.dsLocation = "http://local.fedora.server/fedora/get/#{object.pid}/#{dsid}"
               ds.mimeType = 'image/jpg'
               ds.controlGroup = 'E'
               ds.save
           end
         end
       end

       repository.find_by_sparql("SELECT ?pid FROM <#ri> WHERE {
         ?pid <info:fedora/fedora-system:def/relations-external#isMemberOf> <#{self.uri}> .
                                 
         OPTIONAL { 
           { ?pid <info:wgbh/artesia:relations#ARTESIA.LINKTYPE.ISPLACEDGROF> ?object  } UNION 
           { ?pid <info:wgbh/artesia:relations#BELONGTO> ?object }
         } .

         FILTER(!bound(?object)) }                        
       ").each do |obj|
         obj.memberOfCollection << "info:fedora/wgbh:openvault"
         Blacklight.solr.add obj.to_solr
         obj.save
       end

       Blacklight.solr.commit
     end

     def assetProperties dsid = 'File'
       file = datastream[dsid].content
       # processing?
       @assetProperties ||= Nokogiri::XML(file)
     end

     def assetProperties_links dsid = 'File'
       return @assetProperties_links if @assetProperties_links
       entities = Hash[assetProperties(dsid).internal_subset.children.map { |x| [x.name, x.system_id.split(":").last ] }]
       
       @assetProperties_links ||= assetProperties(dsid).xpath('//LINK').map do |link|
         predicate = "info:wgbh/artesia:relations##{link['LINK_TYPE']}"
         subject = "org.wgbh.mla:#{entities[link['SOURCE']]}"
         object = "org.wgbh.mla:#{entities[link['DESTINATION']]}"

         { :subject => subject, :predicate => predicate, :object => object }
       end.map do |link|
         predicate = case link[:predicate].split("#").last
                       when "PARENT" then "CHILD"
                       when "CHILD" then "PARENT"
                       when "CONTAINS" then "BELONGTO"
                       when "BELONGTO" then "CONTAINS"
                       when "PLACEDGR" then "ARTESIA.LINKTYPE.ISPLACEDGROF"
                       when "ARTESIA.LINKTYPE.ISPLACEDGROF" then "PLACEDGR"
                       else
                     end

         next link if predicate.blank?

         rev = { :subject => link[:object], :predicate => "info:wgbh/artesia:relations##{predicate}", :object => link[:subject] }
         [link, rev]
       end.flatten.uniq
     end
  end
end
