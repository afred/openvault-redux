class FixAudioOnlyRecords < ActiveRecord::Migration
  def self.up
  objs = Rubydora.repository.find_by_sparql 'SELECT ?pid FROM <#ri> WHERE {
{
  ?pid <dc:source> ?source .
 ?pid <info:fedora/fedora-system:def/view#disseminates> ?ds.  
?ds <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/Video.mp4> .
}
FILTER(regex(str(?source), "aif"))
}
'

  objs.each do |obj|
    ds = obj.datastreams['Video.mp4']
    dsLocation = ds.dsLocation
    ds.delete

    ds = obj.datastreams['Audio.mp3']
    ds.controlGroup = 'R'
    ds.dsLocation = dsLocation.gsub('.mp4', '.mp3').gsub('videos', 'audio') 
    ds.save

    ds = obj.datastreams['Audio.flv']
    ds.controlGroup = 'R'
    ds.dsLocation = dsLocation.gsub('.mp4', '.flv').gsub('videos', 'audio') 
    ds.save
  end

  end

  def self.down
  #  raise IrreversibleMigration
  end
end
