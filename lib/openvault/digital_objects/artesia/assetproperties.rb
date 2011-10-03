module Openvault::DigitalObjects::Artesia
  module Assetproperties
     def self.extended(document)
       document.solr_mapping_logic << :assetproperties_metadata_for_solr
     end

     def assetproperties_metadata_for_solr(doc = {})
       doc['format'] = 'asset_properties'
     end

     def uoi_to_pid
       @uoi_to_pid ||= {}
     end

     def process!
       objects = assetProperties.xpath('//UOIS').map do |uois|
         next if uoi_to_pid[uois['UOI_ID']]
         
         pid = nil

         pid ||= "org.wgbh.mla:#{uois.xpath('WGBH_IDENTIFIER[@NOLA_CODE]/@NOLA_CODE').first.to_s.parameterize}" if uois.xpath('WGBH_IDENTIFIER[@NOLA_CODE]/@NOLA_CODE').first

         if uois.xpath('WGBH_RIGHTS[@RIGHTS_HOLDER]/@RIGHTS_HOLDER').first and not uois.xpath('WGBH_RIGHTS[@RIGHTS_HOLDER]/@RIGHTS_HOLDER').first.to_s =~ /wgbh/i
           pid ||= "#{uois.xpath('WGBH_RIGHTS[@RIGHTS_HOLDER]/@RIGHTS_HOLDER').first.to_s.parameterize}:#{uois.xpath('WGBH_SOURCE[@SOURCE_TYPE="Source Reference ID"][not(@SOURCE_NOTE)]/@SOURCE').first.to_s.parameterize}" if uois.xpath('WGBH_SOURCE[@SOURCE_TYPE="Source Reference ID"][not(@SOURCE_NOTE)]/@SOURCE').first 
           pid ||= "#{uois.xpath('WGBH_RIGHTS[@RIGHTS_HOLDER]/@RIGHTS_HOLDER').first.to_s.parameterize}:#{uois.xpath('WGBH_SOURCE[@SOURCE_TYPE="Source Reference"][not(@SOURCE_NOTE)]/@SOURCE').first.to_s.parameterize}" if uois.xpath('WGBH_SOURCE[@SOURCE_TYPE="Source Reference"][not(@SOURCE_NOTE)]/@SOURCE').first 
         end

         pid ||= "org.wgbh.mla:#{uois['UOI_ID']}"

         uoi_to_pid[uois['UOI_ID']] = pid
         print "Deleting #{pid}\n"

         response = Blacklight.solr.find :q => "{!raw f=dc_identifier_s}#{uois['UOI_ID']}"
         response.docs.each { |d| d.fedora_object.delete rescue nil }
         Blacklight.solr.delete_by_query("{!raw f=dc_identifier_s}#{uois['UOI_ID']}")

         Rubydora.repository.find("org.wgbh.mla:#{uois['UOI_ID']}").delete rescue nil
         Rubydora.repository.find(pid).delete rescue nil
         [pid, uois]
       end.compact.tap do |x|
         h = {}
         x.each { |pid, uois| h[pid] ||= 0; h[pid] += 1 }
         x.each_with_index do |(pid, uois), i| 
           x[i] = ["#{pid}-#{uois['UOI_ID'].slice(0,6)}", uois] if h[pid] > 1 and not uois.xpath('WGBH_IDENTIFIER[@NOLA_CODE]/@NOLA_CODE').first
           uoi_to_pid[uois['UOI_ID']] = x[i].first
           Rubydora.repository.find(x[i].first).delete rescue nil 
         end
       end.map do |pid, uois|
         print "Creating #{pid}\n"
         next if uois.xpath('WGBH_RIGHTS/@RIGHTS_NOTE').map { |x| x.to_s }.any? { |x| x =~ /Not to be released to Open Vault/i and not x =~ /text-only record/ }

         obj = Rubydora.repository.find(pid) 
         obj = Rubydora.repository.create(pid) if obj.new? 
         
         obj.models << 'info:fedora/artesia:asset'
         obj.models << 'info:fedora/wgbh:CONCEPT'

         case nola = uois.xpath('WGBH_IDENTIFIER[@NOLA_CODE]/@NOLA_CODE').first.to_s
           when /\d\d/
             obj.models << "info:fedora/wgbh:PROGRAM"
           when /\w\w/
             obj.models << "info:fedora/wgbh:SERIES"
         end

         obj.member_of << self

         ds = obj['UOIS_XML']
         ds.content = uois.to_s
         ds.mimeType = 'text/xml'
         ds.save

         Rubydora.repository.find(obj.pid)
       end.compact.each do |obj|
         assetProperties_links.select { |x| x[:subject] == obj.pid }.each do |link|
           print "#{obj.pid} -> #{link[:predicate]} - #{link[:object]}\n"
           obj.add_relationship(link[:predicate], "info:fedora/#{link[:object]}")
         end
       end.each do |obj|
         obj.add_metadata_sdef_datastreams!
       end.each do |obj|
         uois = Nokogiri::XML(obj['UOIS_XML'].content)
         next if uois.xpath('//WGBH_RIGHTS/@RIGHTS_NOTE').map { |x| x.to_s }.any? { |x| x =~ /text-only record/i }
         name = uois.xpath('//UOIS/@NAME').first.to_s
         name = uois.xpath('//WGBH_SOURCE[@SOURCE_TYPE="Digital Video Essence URL"]/@SOURCE').first.to_s if name =~ /Complete Video/
         files = []
         files = Dir.glob(File.join(Rails.root, "public", "media/**/#{name}"))
         files += Dir.glob(File.join(Rails.root, "public", "media/**/#{File.basename(name, File.extname(name))}.*"))
         files.reject! { |x| x =~ /thumbnails/ }
         files.reject! { |x| x =~ /audio/ and x =~ /flv/ }
         print "#{obj.pid}: #{files.uniq.join(",")}\n"
         obj.add_media_datastreams!(files.uniq)
       end.each do |obj|
         uois = Nokogiri::XML(obj['UOIS_XML'].content)
         name = uois.xpath('//UOIS/@NAME').first.to_s
         name = uois.xpath('//WGBH_SOURCE[@SOURCE_TYPE="Digital Video Essence URL"]/@SOURCE').first.to_s if name =~ /Complete Video/
         files = Dir.glob(File.join(Rails.root, "public", "media/**/#{File.basename(name, File.extname(name))}.*"))
         thumbnail = files.select { |x| x =~ /thumbnails/ }.sort_by { |x| x.length }.first

         if thumbnail
           print "#{obj.pid}[Thumbnail]: #{thumbnail}\n"
           ds = obj['Thumbnail']
           ds.dsLocation = Openvault::Media.filename_to_url(thumbnail)
           ds.mimeType = 'image/jpg'
           ds.controlGroup = 'R'
           ds.save
         end
       end

       sleep 5

       print "info:fedora/wgbh:openvault:\n"
       repository.find_by_sparql("SELECT ?pid FROM <#ri> WHERE {
         ?pid <info:fedora/fedora-system:def/relations-external#isMemberOf> <#{self.uri}> .
                                 
         OPTIONAL { 
           { ?pid <info:wgbh/artesia:relations#ARTESIA.LINKTYPE.ISPLACEDGROF> ?object  } UNION 
           { ?pid <info:wgbh/artesia:relations#BELONGTO> ?object . 
             ?pid <info:fedora/fedora-system:def/view#disseminates> ?dsid .
             ?dsid <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/Transcript.tei.xml>
           }
         } .

         FILTER(!bound(?object)) }                        
       ").each do |obj|
         print "#{obj.pid}\n"
         obj.memberOfCollection << "info:fedora/wgbh:openvault"
         obj.save
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
               print "#{obj.pid}[#{dsid}] = http://local.fedora.server/fedora/get/#{object.pid}/#{dsid}\n"
               ds = obj[dsid]
	       next unless ds.new?
               ds.dsLocation = "http://local.fedora.server/fedora/get/#{object.pid}/#{dsid}"
               ds.mimeType = 'text/xml'
               ds.controlGroup = 'E'
               ds.save

             when "PLACEDGR"                     
               object = Rubydora.repository.find(link[:object])
               dsid = object.datastreams.keys.select { |x| x =~ /Thumbnail/ or x =~ /^Image/ }.first
               next unless dsid
               print "#{obj.pid}[Thumbnail] = http://local.fedora.server/fedora/get/#{object.pid}/#{dsid}\n"
               ds = obj['Thumbnail']
	       next unless ds.new?
               ds.dsLocation = "http://local.fedora.server/fedora/get/#{object.pid}/#{dsid}"
               ds.mimeType = 'image/jpg'
               ds.controlGroup = 'E'
               ds.save
           end
         end
       end

       repository.sparql("SELECT ?tn ?pid FROM <#ri> WHERE {
                            {
                                    ?tn <info:wgbh/artesia:relations#ARTESIA.LINKTYPE.ISPLACEDGROF> ?pid
                            } UNION {
                                    ?pid <info:wgbh/artesia:relations#ARTESIA.LINKTYPE.PLACEDGR> ?tn

                            } .
                                    {
                                    ?tn <info:fedora/fedora-system:def/relations-external#isMemberOf> <#{self.uri}> .
                                    } UNION {
                                    ?pid <info:fedora/fedora-system:def/relations-external#isMemberOf> <#{self.uri}> .
                                    }
                                 }").map { |x| [x['pid'], x['tn']] }.uniq.each do |pid, tn_pid|
         obj = Rubydora.repository.find(pid)
         next if obj.datastreams.keys.include? 'Thumbnail'
         tn = Rubydora.repository.find(tn_pid)
         dsid = tn.datastreams.keys.select { |x| x =~ /Thumbnail/ or x =~ /^Image/ }.first
         print "#{obj.pid}[Thumbnail] = http://local.fedora.server/fedora/get/#{tn.pid}/#{dsid}\n"

         ds = obj['Thumbnail']
         ds.dsLocation = "http://local.fedora.server/fedora/get/#{tn.pid}/#{dsid}"
         ds.mimeType = 'image/jpg'
         ds.controlGroup = 'E'
         ds.save
                                 end

       repository.find_by_sparql("SELECT ?pid FROM <#ri> WHERE {
         ?pid <info:fedora/fedora-system:def/relations-external#isMemberOf> <#{self.uri}> .
                         }").each do |obj|
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
         subject = "#{uoi_to_pid[entities[link['SOURCE']]]}"
         object = "#{uoi_to_pid[entities[link['DESTINATION']]]}"

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
