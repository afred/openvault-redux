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
       Rails.logger.info "Running Openvault::DigitalObjects::Artesia::Assetproperties.process!"

       Rails.logger.debug "Asset Properties XML:"
       Rails.logger.debug assetProperties.to_s
       objects = assetProperties.xpath('//UOIS').map do |uois|
         Rails.logger.info "Processing UOI_ID #{uois['UOI_ID']}"
         if uoi_to_pid[uois['UOI_ID']]
           Rails.logger.info "  Skipping; already processed as PID #{uoi_to_pid[uois['UOI_ID']]}"
           next
         end
         
         pid = nil

         pid ||= "org.wgbh.mla:#{uois.xpath('WGBH_IDENTIFIER[@NOLA_CODE]/@NOLA_CODE').first.to_s.parameterize}" if uois.xpath('WGBH_IDENTIFIER[@NOLA_CODE]/@NOLA_CODE').first

         if uois.xpath('WGBH_RIGHTS[@RIGHTS_HOLDER]/@RIGHTS_HOLDER').first and not uois.xpath('WGBH_RIGHTS[@RIGHTS_HOLDER]/@RIGHTS_HOLDER').first.to_s =~ /wgbh/i
           pid ||= "#{uois.xpath('WGBH_RIGHTS[@RIGHTS_HOLDER]/@RIGHTS_HOLDER').first.to_s.parameterize}:#{uois.xpath('WGBH_SOURCE[@SOURCE_TYPE="Source Reference ID"][not(@SOURCE_NOTE)]/@SOURCE').first.to_s.parameterize}" if uois.xpath('WGBH_SOURCE[@SOURCE_TYPE="Source Reference ID"][not(@SOURCE_NOTE)]/@SOURCE').first 
           pid ||= "#{uois.xpath('WGBH_RIGHTS[@RIGHTS_HOLDER]/@RIGHTS_HOLDER').first.to_s.parameterize}:#{uois.xpath('WGBH_SOURCE[@SOURCE_TYPE="Source Reference"][not(@SOURCE_NOTE)]/@SOURCE').first.to_s.parameterize}" if uois.xpath('WGBH_SOURCE[@SOURCE_TYPE="Source Reference"][not(@SOURCE_NOTE)]/@SOURCE').first 
         end

         pid ||= "org.wgbh.mla:#{uois['UOI_ID']}"

         Rails.logger.info "  As PID #{pid}"

         uoi_to_pid[uois['UOI_ID']] = pid


         Rails.logger.info "  Deleting any existing objects with the same UOI_ID"
         response = Blacklight.solr.find :q => "{!raw f=dc_identifier_s}#{uois['UOI_ID']}"
         response.docs.each do |d| 
           Rails.logger.info "    #{d.fedora_object.pid}" rescue nil
           d.fedora_object.delete rescue nil 
         end
         Blacklight.solr.delete_by_query("{!raw f=dc_identifier_s}#{uois['UOI_ID']}")

         Rails.logger.info "    org.wgbh.mla:#{uois['UOI_ID']}"
         Rubydora.repository.find("org.wgbh.mla:#{uois['UOI_ID']}").delete rescue nil
         Rails.logger.info "    #{pid}"
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
         Rails.logger.info "Creating Fedora object with PID #{pid}\n"
         Rails.logger.info "  Not processing #{pid} because of RIGHTS_NOTE: #{uois.xpath('WGBH_RIGHTS/@RIGHTS_NOTE').map { |x| x.to_s }}" and next if uois.xpath('WGBH_RIGHTS/@RIGHTS_NOTE').map { |x| x.to_s }.any? { |x| x =~ /Not to be released to Open Vault/i and not x =~ /Media not to be released/ }

         obj = Rubydora.repository.find(pid) 
         obj = Rubydora.repository.create(pid) if obj.new? 
         
         Rails.logger.info "  Adding cmodels"
         Rails.logger.info "    info:fedora/artesia:asset"
         obj.models << 'info:fedora/artesia:asset'
         Rails.logger.info "    info:fedora/wgbh:CONCEPT"
         obj.models << 'info:fedora/wgbh:CONCEPT'

         case nola = uois.xpath('WGBH_IDENTIFIER[@NOLA_CODE]/@NOLA_CODE').first.to_s
           when /\d\d/
             Rails.logger.info "    info:fedora/wgbh:PROGRAM"
             obj.models << "info:fedora/wgbh:PROGRAM"
           when /\w\w/
             Rails.logger.info "    info:fedora/wgbh:SERIES"
             obj.models << "info:fedora/wgbh:SERIES"
         end

         obj.member_of << self

         Rails.logger.info "  Adding UOIS_XML datastream" 
         ds = obj['UOIS_XML']
         ds.content = uois.to_s
         ds.mimeType = 'text/xml'
         ds.save

         Rubydora.repository.find(obj.pid)
       end.compact.each do |obj|
         assetProperties_links.select { |x| x[:subject] == obj.pid }.each do |link|
           Rails.logger.info "Adding relation #{obj.pid} -> #{link[:predicate]} - #{link[:object]}\n"
           obj.add_relationship(link[:predicate], "info:fedora/#{link[:object]}")
         end
       end.each do |obj|
         Rails.logger.info "Adding SDef datastreams for #{obj.pid}"
         obj.add_metadata_sdef_datastreams!
       end.each do |obj|
         Rails.logger.info "Adding Media datastreams for #{obj.pid}"
         uois = Nokogiri::XML(obj['UOIS_XML'].content)
         Rails.logger.info "Skipping because of RIGHTS_NOTE: #{uois.xpath('//WGBH_RIGHTS/@RIGHTS_NOTE').map { |x| x.to_s }}" and next if uois.xpath('//WGBH_RIGHTS/@RIGHTS_NOTE').map { |x| x.to_s }.any? { |x| x =~ /Media not to be released/i }
         
         name = uois.xpath('//UOIS/@NAME').first.to_s 
         name = uois.xpath('//WGBH_SOURCE[@SOURCE_TYPE="Digital Video Essence URL"]/@SOURCE').first.to_s if name =~ /Complete Video/
         Rails.logger.info "  Searching for media with base name #{name}"
         files = []
         files = Dir.glob(File.join(Rails.root, "public", "media/**/#{name}"))
         files += Dir.glob(File.join(Rails.root, "public", "media/**/#{File.basename(name, File.extname(name))}.*"))
         files.reject! { |x| x =~ /thumbnails/ }
         files.reject! { |x| x =~ /audio/ and x =~ /flv/ }
         Rails.logger.info "    Found: #{files.uniq.join(",")}"
         obj.add_media_datastreams!(files.uniq)
       end.each do |obj|
         Rails.logger.info "Adding Thumbnail datastreams for #{obj.pid}"
         uois = Nokogiri::XML(obj['UOIS_XML'].content)
         name = uois.xpath('//UOIS/@NAME').first.to_s
         name = uois.xpath('//WGBH_SOURCE[@SOURCE_TYPE="Digital Video Essence URL"]/@SOURCE').first.to_s if name =~ /Complete Video/
         Rails.logger.info "  Searching for thumbnails with base name #{name}"
         files = Dir.glob(File.join(Rails.root, "public", "media/**/#{File.basename(name, File.extname(name))}.*"))
         Rails.logger.info "    Found: #{files.uniq.join(",")}"
         thumbnail = files.select { |x| x =~ /thumbnails/ }.sort_by { |x| x.length }.first
         Rails.logger.info "    Using: #{thumbnail}"

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

       print "Relating salient objects to info:fedora/wgbh:openvault:\n"
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
         Rails.logger.info "Adding #{obj.pid} as memberOfCollection info:fedora/wgbh:openvault"
         obj.memberOfCollection << "info:fedora/wgbh:openvault"
         obj.save
       end


       Rails.logger.info "Reifying related content (thumbnails, transcripts, etc) to 'parent' objects"
       objects.each do |obj|
         # add related files..
         assetProperties_links.select { |x| x[:subject] == obj.pid }.each do |link|
           case link[:predicate].split("#").last
             when "CONTAINS"
               # Transcript
               Rails.logger.info "Found CONTAINS relationship to #{obj.pid}"
               object = Rubydora.repository.find(link[:object])
               dsid = object.datastreams.keys.select { |x| x =~ /\.xml$/ }.first
               Rails.logger.info "  Unable to find Fedora object for #{link[:object]} with an xml datastream" and next unless dsid
               Rails.logger.info "  Adding transcript datastream to #{obj.pid} (from #{object.pid}/#{dsid}"
               print "#{obj.pid}[#{dsid}] = http://local.fedora.server/fedora/get/#{object.pid}/#{dsid}\n"
               ds = obj[dsid]
	       Rails.logger.info "    Cowardly not replacing existing #{dsid}" and next unless ds.new?
               ds.dsLocation = "http://local.fedora.server/fedora/get/#{object.pid}/#{dsid}"
               ds.mimeType = 'text/xml'
               ds.controlGroup = 'E'
               ds.save

             when "PLACEDGR"                     
               Rails.logger.info "Found PLACEDGR relationship to #{obj.pid}"
               object = Rubydora.repository.find(link[:object])
               dsid = object.datastreams.keys.select { |x| x =~ /Thumbnail/ or x =~ /^Image/ }.first
               Rails.logger.info "  Unable to find Fedora object for #{link[:object]} with a thumbnail or image datastream" and next unless dsid
               Rails.logger.info "  Adding thumbnail datastream to #{obj.pid} (from #{object.pid}/#{dsid}"
               print "#{obj.pid}[Thumbnail] = http://local.fedora.server/fedora/get/#{object.pid}/#{dsid}\n"
               ds = obj['Thumbnail']
	       Rails.logger.info "    Cowardly not replacing existing Thumbnail datastream" and next unless ds.new?
               ds.dsLocation = "http://local.fedora.server/fedora/get/#{object.pid}/#{dsid}"
               ds.mimeType = 'image/jpg'
               ds.controlGroup = 'E'
               ds.save
           end
         end
       end

       Rails.logger.info "Adding collection-based thumbnails (??)"
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

       Rails.logger.info "Adding objects to Solr"
       repository.find_by_sparql("SELECT ?pid FROM <#ri> WHERE {
         ?pid <info:fedora/fedora-system:def/relations-external#isMemberOf> <#{self.uri}> .
                         }").each do |obj|
       Rails.logger.info " - #{obj.pid}"
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
