module Artesia
  module TeamsAssetFile 

    def self.extended(object)
    end

    def self.create dataset, pid = nil
      doc = Nokogiri::XML(open(dataset.attachment.path))
      metadata = Hash[*doc.xpath('//TEAMS_ASSET_FILE[1]').children.find_all { |x| x.comment? }.first.text.scan(/ (\S+)="([^"]+)"/).flatten]
      pid ||= "teams-asset-file:#{metadata["name"]}"
      obj = Fedora::FedoraObject.create(pid, { :label => metadata['description'], :logMessage => ""})
      Fedora::Datastream.new('File',{}, doc.to_s, 'text/xml').add(obj.client)
      Fedora.repository.soap.addRelationship :pid => pid, :relationship => 'info:fedora/fedora-system:def/model#hasModel', :object => "info:fedora/artesia:teams-asset-file", :isLiteral => false, :datatype => nil

      Fedora::FedoraObject.find(pid)
    end

    def doc
      @doc ||= Nokogiri::XML(self.datastream('File'))
    end

    def process!
      self.doc.xpath('//ASSET').each do |el|
        obj = Artesia::Asset.create(el.to_s)
        Fedora.repository.soap.addRelationship :pid => obj.pid, :relationship => 'info:fedora/fedora-system:def/relations-external#isMemberOfCollection', :object => "info:fedora/#{@pid}", :isLiteral => false, :datatype => nil
      end
      create_relationships
    end

    protected

    def create_relationships
      entities = Hash[*self.doc.children.first.children.find_all { |x| x.type == Nokogiri::XML::Node::ENTITY_DECL }.map { |x|[ x.name, x.system_id.gsub('teams:/query-uoi?uois:uoi_id:eq:', 'info:fedora/uoi-id:')] }.flatten]

      self.doc.xpath('//LINK').each do |link|
        options = {:subject => entities[link['SOURCE']], :relationship => link['LINK_TYPE'], :object => entities[link['DESTINATION']]}
      Fedora.repository.soap.addRelationship :pid => options[:subject], :relationship => "info:artesia/link_type##{options[:relationship]}", :object => "info:fedora/#{options[:object]}", :isLiteral => false, :datatype => nil
      end
    end
  end
end
