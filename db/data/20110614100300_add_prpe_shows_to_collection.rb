class AddPrpeShowsToCollection < ActiveRecord::Migration
  def self.up
    objs = Rubydora.repository.find_by_sparql %Q{
      SELECT ?pid FROM <#ri> WHERE {
        ?pid <http://purl.org/dc/elements/1.1/contributor> "Lyons, Louis Martin, 1897-" 
    }
    }

    objs.each do |obj|
      obj.memberOfCollection << "info:fedora/org.wgbh.mla:prpe"
    end
  end

  def self.down

  end
end
