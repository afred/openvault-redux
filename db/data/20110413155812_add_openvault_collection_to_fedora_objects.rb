class AddOpenvaultCollectionToFedoraObjects < ActiveRecord::Migration
  def self.up
    concept_pids = Rubydora.repository.sparql 'SELECT ?pid FROM <#ri> WHERE {
  {
    ?pid <info:fedora/fedora-system:def/model#hasModel> <info:fedora/wgbh:CONCEPT>
  } UNION {
    ?pid <info:fedora/fedora-system:def/model#hasModel> <info:fedora/wgbh:COLLECTION>
  }.
 OPTIONAL {
    ?pid <info:fedora/fedora-system:def/relations-external#isThumbnailOf> ?tn
  } .
  FILTER(!bound(?tn)) . 
}'

    concept_pids.map { |x| x['pid'] }.each do |pid|
      Rubydora.repository.soap.addRelationship(:pid => pid.gsub('info:fedora/', ''), :relationship => 'info:fedora/fedora-system:def/relations-external#isMemberOfCollection', :object => 'info:fedora/wgbh:openvault', :isLiteral => false, :datatype => nil)
    end
  end

  def self.down

  end
end
