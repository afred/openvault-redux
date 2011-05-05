class AddMediaDatastreamsToObjects < ActiveRecord::Migration
  def self.up
pids_to_assets = Rubydora.repository.sparql '
SELECT ?pid ?child ?cmodel ?ds FROM <#ri> WHERE {
  {
    ?pid <info:fedora/fedora-system:def/model#hasModel> <info:fedora/wgbh:CONCEPT>.
    ?child <info:fedora/fedora-system:def/relations-external#isPartOf> ?pid.
    ?child <info:fedora/fedora-system:def/model#hasModel> ?cmodel.
    ?child <info:fedora/fedora-system:def/view#disseminates> ?ds.
    ?ds  <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/Proxy>
  } UNION   {
    ?pid <info:fedora/fedora-system:def/model#hasModel> <info:fedora/wgbh:CONCEPT>.
    ?child <info:fedora/fedora-system:def/relations-external#isPartOf> ?pid.
    ?child <info:fedora/fedora-system:def/model#hasModel> ?cmodel.
    ?child <info:fedora/fedora-system:def/view#disseminates> ?ds.
    ?ds  <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/File>
  } UNION   {
    ?pid <info:fedora/fedora-system:def/model#hasModel> <info:fedora/wgbh:CONCEPT>.
    ?child <info:fedora/fedora-system:def/relations-external#isPartOf> ?pid.
    ?child <info:fedora/fedora-system:def/model#hasModel> ?cmodel.
    ?child <info:fedora/fedora-system:def/view#disseminates> ?ds.
    ?ds  <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/Full>
  } UNION   {
    ?pid <info:fedora/fedora-system:def/model#hasModel> <info:fedora/wgbh:CONCEPT>.
    ?asset <info:fedora/fedora-system:def/relations-external#isPartOf> ?pid.
    ?child <info:fedora/fedora-system:def/relations-external#isPartOf> ?asset.
    ?child <info:fedora/fedora-system:def/model#hasModel> ?cmodel.
    ?child <info:fedora/fedora-system:def/view#disseminates> ?ds.
    ?ds  <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/File>
  }

    FILTER(?cmodel != <info:fedora/fedora-system:FedoraObject-3.0>) 
}'


 pids_to_assets.each do |arr|
   obj = Rubydora.repository.find(arr['pid'])
   print arr['pid'] + " " + arr['ds']
   headers = Streamly.head 'http://localhost:8180/fedora/get/' + arr['ds'].gsub('info:fedora/', '')

   case arr['cmodel']
     when /VIDEO/
       if headers =~ /302 Found/
         ds = obj.datastream['Video.mp4']
         ds.controlGroup = 'R'
         ds.dsLocation = headers.scan(/Location: ([^\r]+)/).flatten.first 
         ds.mimeType = 'video/mp4'
         ds.save
       else
         print "??"
       end
       # Proxy -> x/Video_mp4

     when /AUDIO/
       if headers =~ /302 Found/
         ds = obj.datastream['Audio.flv']
         ds.controlGroup = 'R'
         ds.dsLocation = headers.scan(/Location: ([^\r]+)/).flatten.first 
         ds.mimeType = 'video/x-flv'
         ds.save

         ds = obj.datastream['Audio.mp3']
         ds.controlGroup = 'R'
         ds.dsLocation = headers.scan(/Location: ([^\r]+)/).flatten.first.gsub('flv', 'mp3') 
         ds.mimeType = 'audio/mp3'
         ds.save
       else
         print "??"
       end
       # Proxy -> x/Audio_flv

     when /IMAGE/
       ds = obj.datastream['Image.jpg']
       ds.mimeType = 'image/jpg'
       if headers =~ /302 Found/
         ds.controlGroup = 'R'
         ds.dsLocation = headers.scan(/Location: ([^\r]+)/).flatten.first 
       else
         ds.controlGroup = 'M'
         ds.content = Streamly.get('http://localhost:8180/fedora/get/' + arr['ds'].gsub('info:fedora/', ''))
       end
       ds.save


     when /LOG_NEWSML/
         ds = obj.datastream['Transcript.newsml.xml']
         ds.mimeType = 'text/xml'
       if headers =~ /302 Found/
         ds.controlGroup = 'R'
         ds.dsLocation = headers.scan(/Location: ([^\r]+)/).flatten.first 
       else
         ds.controlGroup = 'M'
         ds.content = Streamly.get('http://localhost:8180/fedora/get/' + arr['ds'].gsub('info:fedora/', ''))
       end
       # File -> x/Transcript_NEWSML
       ds.save

     when /LOG/
         ds = obj.datastream['Transcript.tei.xml']
         ds.mimeType = 'text/xml'
       if headers =~ /302 Found/
         ds.controlGroup = 'R'
         ds.dsLocation = headers.scan(/Location: ([^\r]+)/).flatten.first 
         ds.save
       else
         ds.controlGroup = 'M'
         ds.content = Streamly.get('http://localhost:8180/fedora/get/' + arr['ds'].gsub('info:fedora/', ''))
       end
       # File -> x/Transcript_TEI

   end

   print "\n"

  end
  end

  def self.down
  end
end
