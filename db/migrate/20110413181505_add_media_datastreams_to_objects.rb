class AddMediaDatastreamsToObjects < ActiveRecord::Migration
  def self.up
pids_to_assets = Fedora.repository.sparql '
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
   client = Fedora::FedoraObject.find(arr['pid'].gsub('info:fedora/', '')).client
   print arr['pid'] + " " + arr['ds']
   headers = Streamly.head 'http://localhost:8180/fedora/get/' + arr['ds'].gsub('info:fedora/', '')

   case arr['cmodel']
     when /VIDEO/
       if headers =~ /302 Found/
         Fedora::Datastream.new('Video.mp4', {:controlGroup => 'R', :dsLocation => headers.scan(/Location: ([^\r]+)/).flatten.first, :mimeType => 'video/mp4' }).add(client)
       else
         print "??"
       end
       # Proxy -> x/Video_mp4

     when /AUDIO/
       if headers =~ /302 Found/
         Fedora::Datastream.new('Audio.flv', {:controlGroup => 'R', :dsLocation => headers.scan(/Location: ([^\r]+)/).flatten.first, :mimeType => 'video/x-flv' }).add(client)
         Fedora::Datastream.new('Audio.mp3', {:controlGroup => 'R', :dsLocation => headers.scan(/Location: ([^\r]+)/).flatten.first.gsub('flv', 'mp3'), :mimeType => 'audio/mp3' }).add(client)
       else
         print "??"
       end
       # Proxy -> x/Audio_flv

     when /IMAGE/
       if headers =~ /302 Found/
         Fedora::Datastream.new('Image.jpg', {:controlGroup => 'R', :dsLocation => headers.scan(/Location: ([^\r]+)/).flatten.first, :mimeType => 'image/jpg' }).add(client)
       else
         Fedora::Datastream.new('Image.jpg', {:controlGroup => 'M'}, Streamly.get('http://localhost:8180/fedora/get/' + arr['ds'].gsub('info:fedora/', '')), 'image/jpg').add(client)
       end


     when /LOG_NEWSML/
       if headers =~ /302 Found/
         Fedora::Datastream.new('Transcript.newsml.xml', {:controlGroup => 'R', :dsLocation => headers.scan(/Location: ([^\r]+)/).flatten.first, :mimeType => 'text/xml' }).add(client)
       else
         Fedora::Datastream.new('Transcript.newsml.xml', {:controlGroup => 'M'}, Streamly.get('http://localhost:8180/fedora/get/' + arr['ds'].gsub('info:fedora/', '')), 'text/xml').add(client)
       end
       # File -> x/Transcript_NEWSML

     when /LOG/
       if headers =~ /302 Found/
         Fedora::Datastream.new('Transcript.tei.xml', {:controlGroup => 'R', :dsLocation => headers.scan(/Location: ([^\r]+)/).flatten.first, :mimeType => 'text/xml' }).add(client)
       else
         Fedora::Datastream.new('Transcript.tei.xml', {:controlGroup => 'M'}, Streamly.get('http://localhost:8180/fedora/get/' + arr['ds'].gsub('info:fedora/', '')), 'text/xml').add(client)
       end
       # File -> x/Transcript_TEI

   end

   print "\n"

  end
  end

  def self.down
  end
end
