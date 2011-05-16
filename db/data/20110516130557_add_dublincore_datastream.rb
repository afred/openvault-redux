class AddDublincoreDatastream < ActiveRecord::Migration
  def self.up
    objs = Rubydora.repository.find_by_sparql 'SELECT ?pid FROM <#ri> WHERE {
      ?pid  <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> <info:fedora/wgbh:openvault>  .
      OPTIONAL {
        ?pid <info:fedora/fedora-system:def/view#disseminates> ?ds.
       ?ds <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/DublinCore>
      }
  FILTER(!bound(?ds)) . 
}'

    objs.each do |obj|
      ds = obj.datastreams['DublinCore']
      ds.controlGroup = 'E'
      ds.dsLocation = "http://local.fedora.server/fedora/#{obj.datastreams['DC'].url}"
      ds.save
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end
