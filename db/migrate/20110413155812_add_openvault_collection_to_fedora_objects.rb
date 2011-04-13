class AddOpenvaultCollectionToFedoraObjects < ActiveRecord::Migration
  def self.up
    concept_pids = Fedora.repository.sparql 'SELECT ?pid FROM <#ri> WHERE {
  {
    ?pid <info:fedora/fedora-system:def/model#hasModel> <info:fedora/wgbh:CONCEPT>
  } UNION {
    ?pid <info:fedora/fedora-system:def/model#hasModel> <info:fedora/wgbh:COLLECTION>
  }
}'

    concept_pids.map { |x| x['pid'].gsub('info:fedora/', '') }.each do |pid|
      Fedora.repository.soap.addRelationship(:pid => pid, :relationship => 'info:fedora/fedora-system:def/relations-external#isMemberOfCollection', :object => 'info:fedora/wgbh:openvault', :isLiteral => false, :datatype => nil)
    end
  end

  def self.down

  end
end
