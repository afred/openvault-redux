class AddThumbnailsToFedoraObjects < ActiveRecord::Migration
  def self.up

    thumbnail_disseminations_sparql = ['Thumbnail', '__tn_large', '__tn_preview'].map { |x| "?tds <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/#{x}>" }.join " } UNION { " 

    thumbnail_disseminations_sparql = "{#{thumbnail_disseminations_sparql}}"
pids_to_tnds = Rubydora.repository.sparql "
SELECT ?pid ?tds FROM <#ri> WHERE {{
  ?pid <info:fedora/fedora-system:def/model#hasModel> <info:fedora/wgbh:CONCEPT>.
  {
    ?child <info:fedora/fedora-system:def/relations-external#isPartOf> ?pid.
    ?child <info:fedora/fedora-system:def/view#disseminates> ?tds.
    #{ thumbnail_disseminations_sparql }
  } UNION {
     ?pid <info:fedora/fedora-system:def/view#disseminates> ?tds.
    #{ thumbnail_disseminations_sparql }
  } UNION {
    ?pid <info:fedora/fedora-system:def/relations-external#hasThumbnail> ?tn .
    ?tn <info:fedora/fedora-system:def/view#disseminates> ?tds.
    #{ thumbnail_disseminations_sparql }
  } UNION {
    ?tn <info:fedora/fedora-system:def/relations-external#isThumbnailOf> ?pid .
    ?tn <info:fedora/fedora-system:def/view#disseminates> ?tds.
    #{ thumbnail_disseminations_sparql }
  } UNION {
     ?child <info:fedora/fedora-system:def/relations-external#isPartOf> ?pid.  
     ?child <info:fedora/fedora-system:def/relations-external#hasThumbnail> ?tn .
     ?tn <info:fedora/fedora-system:def/view#disseminates> ?tds.
    #{ thumbnail_disseminations_sparql }
  } UNION {
     ?child <info:fedora/fedora-system:def/relations-external#isPartOf> ?pid.  
     ?tn <info:fedora/fedora-system:def/relations-external#isThumbnailOf> ?child .
     ?tn <info:fedora/fedora-system:def/view#disseminates> ?tds.
    #{ thumbnail_disseminations_sparql }
  }
  }  
}"

 pids_to_tnds.map { |x| [x['pid'].gsub('info:fedora/', ''), x['tds'].gsub('info:fedora/', '') ] }.each do |k, v|
   obj = Rubydora.repository.find(k)
   begin
   raise "404/500" if Streamly.head('http://localhost:8180/fedora/get/' + k + '/Thumbnail') =~ / (404|500) /
   rescue
     print "#{obj.pid}\n"
     ds = obj.datastream['Thumbnail']
     ds.controlGroup = 'M'
     ds.mimeType = 'image/jpg'
     begin
     ds.file = open('http://localhost:8180/fedora/get/' + v) 
     ds.save 
     rescue 
       nil
     end
   end
 end

objs =  Rubydora.repository.find_by_sparql 'SELECT ?pid FROM <#ri> WHERE {
  ?pid <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> <info:fedora/umb:collection-id-11>
}'

objs.each do |obj|
   ds = obj.datastream['Thumbnail'] 
   ds.controlGroup = 'M'
   ds.mimeType = 'image/jpg'
   ds.dsLocation = "http://local.fedora.server/fedora/get/#{obj.pid}_file/Preview"
   ds.save rescue nil
end

pids_to_collection = Rubydora.repository.sparql '
SELECT ?pid ?collection FROM <#ri> WHERE {
    ?pid <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> ?collection .
    ?pid <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> <info:fedora/wgbh:openvault>.
   OPTIONAL {  { ?pid <info:fedora/fedora-system:def/view#disseminates> ?tn .
     ?tn <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/Thumbnail>
  } UNION {
    ?pid <info:fedora/fedora-system:def/relations-external#hasThumbnail> ?tn .
  } }.
  FILTER(!bound(?tn)) .
  FILTER(!regex(str(?collection), "openvault"))
}'

h = {}

pids_to_collection.sort_by { |x| x['pid'].last.length }.reverse.each do |x|
  next if h['pid']
  h[x['pid']] = true

  obj = Rubydora.repository.find(x['pid'])
  print "#{obj.pid}\n"

   ds = obj.datastream['Thumbnail'] 
   ds.controlGroup = 'E'
   ds.mimeType = 'image/jpg'
   ds.dsLocation =  "http://local.fedora.server/fedora/get/#{x['collection'].gsub('info:fedora/', '')}/Thumbnail"
   ds.save rescue nil
end


  end

  def self.down
  end
end
