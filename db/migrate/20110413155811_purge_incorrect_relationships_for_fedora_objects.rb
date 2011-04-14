class PurgeIncorrectRelationshipsForFedoraObjects < ActiveRecord::Migration
  def self.up
    rels = Fedora.repository.sparql '
      SELECT ?pid  ?object FROM <#ri> WHERE {
         ?pid <info:fedora/fedora-system:def/relations-external#isThumbnailOf> ?object .

        FILTER(regex(str(?object), "thumbnail"))
      }
    '

    rels.each do |r|
      Fedora.repository.soap.purgeRelationship(:pid => r['pid'].gsub('info:fedora/', ''), :relationship => 'info:fedora/fedora-system:def/relations-external#isThumbnailOf', :object => r['object'], :isLiteral => false, :datatype => nil)
    end
  end

  def self.down

  end
end 
