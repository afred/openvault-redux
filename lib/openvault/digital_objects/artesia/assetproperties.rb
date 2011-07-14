module Openvault::DigitalObjects::Artesia
  module Assetproperties
     def self.extended(document)
       document.solr_mapping_logic << :assetproperties_metadata_for_solr
     end

     def assetproperties_metadata_for_solr(doc = {})
       doc['format'] = 'asset_properties'
     end

     def process!
       uoi_ids = {}
       objects = assetProperties.xpath('//UOIS').map do |uois|
         next if uoi_ids[uois['UOI_ID']]
         next if uois.xpath('WGBH_RIGHTS/@RIGHTS_NOTE').map { |x| x.to_s }.any? { |x| x =~ /Not to be released to Open Vault/i and not x =~ /text-only record/ }
         uoi_ids[uois['UOI_ID']] = true
         Rubydora.repository.find("org.wgbh.mla:#{uois['UOI_ID']}").delete rescue nil

         obj = Rubydora.repository.create("org.wgbh.mla:#{uois['UOI_ID']}") 
         print "Created: #{obj.pid} \n"
         
         obj.models << 'info:fedora/artesia:asset'
         obj.models << 'info:fedora/wgbh:CONCEPT'

         obj.member_of << self

         ds = obj['UOIS_XML']
         ds.content = uois.to_s
         ds.mimeType = 'text/xml'
         ds.save

         Rubydora.repository.find(obj.pid)
       end.compact.each do |obj|
         print "Adding Relationships: #{obj.pid}]n"
         assetProperties_links.select { |x| x[:subject] == obj.pid }.each do |link|
           print "   ^-- -> #{link[:predicate]} -> #{link[:object] } "
           obj.add_relationship(link[:predicate], "info:fedora/#{link[:object]}")
         end
       end.each do |obj|
         obj.add_metadata_sdef_datastreams!
       end.each do |obj|
         uois = Nokogiri::XML(obj['UOIS_XML'].content)
         next if uois.xpath('//WGBH_RIGHTS/@RIGHTS_NOTE').map { |x| x.to_s }.any? { |x| x =~ /text-only record/i }
         name = uois.xpath('//UOIS/@NAME').first.to_s
         files = []
         files = Dir.glob(File.join(Rails.root, "public", "media/**/#{name}"))
         files += Dir.glob(File.join(Rails.root, "public", "media/**/#{File.basename(name, File.extname(name))}.*"))
         files.reject! { |x| x =~ /thumbnails\/.*\// }
         files.reject! { |x| x =~ /audio/ and x =~ /flv/ }
         obj.add_media_datastreams!(files.uniq)
       end.each do |obj|
         uois = Nokogiri::XML(obj['UOIS_XML'].content)
         name = uois.xpath('//UOIS/@NAME').first.to_s
         files = Dir.glob(File.join(Rails.root, "public", "media/**/#{File.basename(name, File.extname(name))}.*"))
         thumbnail = files.select { |x| x =~ /thumbnails\/.*\// }.sort_by { |x| x.length }.first

         if thumbnail
           ds = obj['Thumbnail']
           ds.dsLocation = Openvault::Media.filename_to_url(thumbnail)
           ds.mimeType = 'image/jpg'
           ds.controlGroup = 'R'
           ds.save
         end


       end

       objects.each do |obj|
         # add related files..
         assetProperties_links.select { |x| x[:subject] == obj.pid }.each do |link|
           case link[:predicate].split("#").last
             when "CONTAINS"
               # Transcript
               object = Rubydora.repository.find(link[:object])
               dsid = object.datastreams.keys.select { |x| x =~ /\.xml$/ }.first
               next unless dsid
               ds = obj[dsid]
               ds.dsLocation = "http://local.fedora.server/fedora/get/#{object.pid}/#{dsid}"
               ds.mimeType = 'text/xml'
               ds.controlGroup = 'E'
               ds.save

             when "PLACEDGR"                     
               object = Rubydora.repository.find(link[:object])
               dsid = object.datastreams.keys.select { |x| x =~ /^Image/ }.first
               next unless dsid
               ds = obj['Thumbnail']
               ds.dsLocation = "http://local.fedora.server/fedora/get/#{object.pid}/#{dsid}"
               ds.mimeType = 'image/jpg'
               ds.controlGroup = 'E'
               ds.save
           end
         end
       end

       sleep(5)

       repository.find_by_sparql("SELECT ?pid FROM <#ri> WHERE {
         ?pid <info:fedora/fedora-system:def/relations-external#isMemberOf> <#{self.uri}> .
                                 
         OPTIONAL { 
           { ?pid <info:wgbh/artesia:relations#ARTESIA.LINKTYPE.ISPLACEDGROF> ?object  } UNION 
           { ?pid <info:wgbh/artesia:relations#BELONGTO> ?object }
         } .

         FILTER(!bound(?object)) }                        
       ").each do |obj|
         obj.memberOfCollection << "info:fedora/wgbh:openvault"
         sleep 1  
         obj.save
         Blacklight.solr.add obj.to_solr
       end

       Blacklight.solr.commit
     end

     def assetProperties dsid = 'File'
       file = datastream[dsid].content
       # processing?
       @assetProperties ||= begin
                              doc = Nokogiri::XML(file)
                              doc.xpath('//@*').select { |x| x.name =~ /TYPE/ or x.name =~ /ROLE/ }.select { |x| x.value =~ /\d$/ }.each { |x| x.value = x.value.gsub(/\d$/, '') }
                              doc
                            end
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

         relsext = case link[:predicate].split("#").last
                   when "CHILD"
                     { :subject => link[:subject], :predicate => "info:fedora/fedora-system:def/relations-external#isMemberOfCollection", :object => link[:object] }
                   when "BELONGTO"
                     { :subject => link[:subject], :predicate => "info:fedora/fedora-system:def/relations-external#isPartOf", :object => link[:object] }

                   end
         [link, rev, relsext]
       end.flatten.compact.uniq
     end
  end
end
