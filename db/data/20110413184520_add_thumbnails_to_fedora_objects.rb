class AddThumbnailsToFedoraObjects < ActiveRecord::Migration
  def self.up
    require 'open-uri'

    thumbnail_disseminations_sparql = ['Thumbnail', '__tn_large', '__tn_preview'].map { |x| "?tds <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/#{x}>" }.join " } UNION { " 

    thumbnail_disseminations_sparql = "{#{thumbnail_disseminations_sparql}}"
pids_to_tnds = Rubydora.repository.sparql "
SELECT ?pid ?tds FROM <#ri> WHERE {{
  ?pid <info:fedora/fedora-system:def/model#hasModel> <info:fedora/wgbh:CONCEPT>.
  {
    ?child <info:fedora/fedora-system:def/relations-external#isPartOf> ?pid.
    ?child <info:fedora/fedora-system:def/view#disseminates> ?tds.
    { #{ thumbnail_disseminations_sparql } }
  } UNION {
     ?pid <info:fedora/fedora-system:def/view#disseminates> ?tds.
    { #{ thumbnail_disseminations_sparql } }
  } UNION {
    ?pid <info:fedora/fedora-system:def/relations-external#hasThumbnail> ?tn .
    ?tn <info:fedora/fedora-system:def/view#disseminates> ?tds.
    { #{ thumbnail_disseminations_sparql } }
  } UNION {
    ?tn <info:fedora/fedora-system:def/relations-external#isThumbnailOf> ?pid .
    ?tn <info:fedora/fedora-system:def/view#disseminates> ?tds.
    { #{ thumbnail_disseminations_sparql } }
  } UNION {
     ?child <info:fedora/fedora-system:def/relations-external#isPartOf> ?pid.  
     ?child <info:fedora/fedora-system:def/relations-external#hasThumbnail> ?tn .
     ?tn <info:fedora/fedora-system:def/view#disseminates> ?tds.
    { #{ thumbnail_disseminations_sparql } }
  } UNION {
     ?child <info:fedora/fedora-system:def/relations-external#isPartOf> ?pid.  
     ?tn <info:fedora/fedora-system:def/relations-external#isThumbnailOf> ?child .
     ?tn <info:fedora/fedora-system:def/view#disseminates> ?tds.
    { #{ thumbnail_disseminations_sparql } }
  }
  } 

  OPTIONAL {
    ?pid <info:fedora/fedora-system:def/view#disseminates> ?existing_thumbnail_ds .
    ?existing_thumbnail_ds <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/Thumbnail>
  }

  FILTER(!bound(?existing_thumbnail_ds)) .
}"

 pids_to_tnds.map { |x| [x['pid'].gsub('info:fedora/', ''), x['tds'].gsub('info:fedora/', '') ] }.each do |k, v|
   obj = Rubydora.repository.find(k)
   next if obj.datastreams.keys.include? 'Thumbnail'

   data = open('http://localhost:8180/fedora/get/' + v)  rescue nil
   next if data.nil?

   print "#{obj.pid}\n"

   ds = obj.datastream['Thumbnail']
   ds.controlGroup = 'M'
   ds.mimeType = 'image/jpg'
   ds.dsLocation = "http://local.fedora.server/fedora/get/#{v}"
   ds.save 
 end

objs =  Rubydora.repository.find_by_sparql 'SELECT ?pid FROM <#ri> WHERE {
  ?pid <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> <info:fedora/umb:collection-id-11> .

  OPTIONAL {
    ?pid <info:fedora/fedora-system:def/view#disseminates> ?existing_thumbnail_ds .
    ?existing_thumbnail_ds <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/Thumbnail>
  }

  FILTER(!bound(?existing_thumbnail_ds)) .
}'

objs.each do |obj|
   next if obj.datastreams.keys.include? 'Thumbnail'
   ds = obj.datastream['Thumbnail'] 
   ds.controlGroup = 'M'
   ds.mimeType = 'image/jpg'
   ds.dsLocation = "http://local.fedora.server/fedora/get/#{obj.pid}_file/Preview"
   ds.save 
end

pids_to_collection = Rubydora.repository.sparql '
SELECT ?pid ?collection FROM <#ri> WHERE {
    ?pid <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> ?collection .
    ?pid <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> <info:fedora/wgbh:openvault>.
  OPTIONAL {
    ?pid <info:fedora/fedora-system:def/view#disseminates> ?existing_thumbnail_ds .
    ?existing_thumbnail_ds <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/Thumbnail>
  }

  FILTER(!bound(?existing_thumbnail_ds)) .
  FILTER(!regex(str(?collection), "openvault"))
}'

pids_to_collection.sort_by { |x| x['pid'].last.length }.reverse.each do |x|
  obj = Rubydora.repository.find(x['pid'])
  next if obj.datastreams.keys.include? 'Thumbnail'
  print "#{obj.pid}\n"

  ds = obj.datastream['Thumbnail'] 
  ds.controlGroup = 'E'
  ds.mimeType = 'image/jpg'
  ds.dsLocation =  "http://local.fedora.server/fedora/get/#{x['collection'].gsub('info:fedora/', '')}/Thumbnail"
  ds.save
end


  end

  def self.down
  end
end
