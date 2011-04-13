class AddThumbnailsToFedoraObjects < ActiveRecord::Migration
  def self.up
pids_to_tnds = Fedora.repository.sparql '
SELECT ?pid ?tds FROM <#ri> WHERE {{
  ?pid <info:fedora/fedora-system:def/model#hasModel> <info:fedora/wgbh:CONCEPT>.
  ?child <info:fedora/fedora-system:def/relations-external#isPartOf> ?pid.
  ?child <info:fedora/fedora-system:def/view#disseminates> ?tds.
  ?tds  <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/Thumbnail>
} UNION {
  ?pid <info:fedora/fedora-system:def/model#hasModel> <info:fedora/wgbh:CONCEPT>.
  ?child <info:fedora/fedora-system:def/relations-external#isPartOf> ?pid.
  ?child <info:fedora/fedora-system:def/view#disseminates> ?tds.
  ?tds  <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/__tn_large>
} UNION {
  ?pid <info:fedora/fedora-system:def/model#hasModel> <info:fedora/wgbh:CONCEPT>.
  ?child <info:fedora/fedora-system:def/relations-external#isPartOf> ?pid.
  ?child <info:fedora/fedora-system:def/view#disseminates> ?tds.
  ?tds  <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/__tn_preview>
} UNION {
  ?pid <info:fedora/fedora-system:def/model#hasModel> <info:fedora/wgbh:CONCEPT>.
  ?pid <info:fedora/fedora-system:def/view#disseminates> ?tds.
  ?tds  <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/Thumbnail>
} UNION {
  ?pid <info:fedora/fedora-system:def/model#hasModel> <info:fedora/wgbh:CONCEPT>.
  ?pid <info:fedora/fedora-system:def/view#disseminates> ?tds.
  ?tds  <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/__tn_large>
} UNION {
  ?pid <info:fedora/fedora-system:def/model#hasModel> <info:fedora/wgbh:CONCEPT>.
  ?pid <info:fedora/fedora-system:def/relations-external#hasThumbnail> ?tn .
  ?tn <info:fedora/fedora-system:def/view#disseminates> ?tds.
  ?tds  <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/Thumbnail>
} UNION {
  ?pid <info:fedora/fedora-system:def/model#hasModel> <info:fedora/wgbh:CONCEPT>.
  ?child <info:fedora/fedora-system:def/relations-external#isPartOf> ?pid.
  ?child <info:fedora/fedora-system:def/relations-external#hasThumbnail> ?tn .
  ?tn <info:fedora/fedora-system:def/view#disseminates> ?tds.
  ?tds  <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/Thumbnail>
}
}'


 pids_to_tnds.map { |x| [x['pid'].gsub('info:fedora/', ''), x['tds'].gsub('info:fedora/', '') ] }.each do |k, v|
   obj = Fedora::FedoraObject.find(k)
   begin
   raise "404/500" if Streamly.head('http://localhost:8180/fedora/get/' + k + '/Thumbnail') =~ / (404|500) /
   rescue
     print "#{obj.pid}\n"
     Fedora::Datastream.new('Thumbnail', {:controlGroup => 'M', :mimeType => 'image/jpg' }, open('http://localhost:8180/fedora/get/' + v), :content_type => 'image/jpg').add(obj.client) rescue nil
   end
 end

pids =  Fedora.repository.sparql 'SELECT ?pid FROM <#ri> WHERE {
  ?pid <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> <info:fedora/umb:collection-id-11>
}'

pids.map { |x| x['pid'].gsub 'info:fedora/', '' }.each do |pid|
   obj = Fedora::FedoraObject.find(pid)
   Fedora::Datastream.new('Thumbnail', {:controlGroup => 'E', :mimeType => 'image/jpg', :dsLocation => "http://local.fedora.server/fedora/get/#{obj.pid}/Image.jpg" }).add(obj.client) rescue nil
end

pids_to_collection = Fedora.repository.sparql '
SELECT ?pid ?collection FROM <#ri> WHERE {
    ?pid <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> ?collection .
    ?pid <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> <info:fedora/org.wgbh.openvault>.
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
  next if h[pid]
  h[x['pid']] = true

  obj = Fedora::FedoraObject.find(x['pid'].gsub('info:fedora/', ''))
  print "#{obj.pid}\n"

  Fedora.Datastream.new('Thumbnail', {:controlGroup => 'E', :dsLocation => "http://local.fedora.server/fedora/get/#{collection.gsub('info:fedora/', '')}/Thumbnail", :mimeType => 'image/jpg'}).add(obj.client)
  
end


  end

  def self.down
  end
end
