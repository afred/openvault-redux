module Artesia
  module Asset
    def self.extended(object)
    end

    def self.create metadata
      el = Nokogiri::XML(metadata)
      uois = el.xpath('//UOIS').first
      pid = "uoi-id:#{uois['UOI_ID']}"
      obj = Fedora::FedoraObject.create(pid, { :label => uois['NAME'] })
      Fedora::Datastream.new('UOIS', {}, uois.to_s, 'text/xml').add(obj.client)
      Fedora::Datastream.new('File', {:controlGroup => 'R', :dsLabel => uois['NAME'], :dsLocation => "http://somewh
ere.in.artesia/#{uois['NAME']}" }).add(obj.client)
      Fedora.repository.soap.addRelationship :pid => pid, :relationship => 'info:fedora/fedora-system:def/model#hasModel', :object => "info:fedora/artesia:asset", :isLiteral => false, :datatype => nil
      obj
    end

    def doc
      @doc ||= Nokogiri::XML(self.datastream('UOIS'))
    end

    def validate_datastreams
      validate_datastreams
    end

    def publish
      return unless validate_datastreams
      publish!
    end

    def publish!
      pid = self.pid.gsub('uoi-id', 'org.wgbh.mla')

      obj = Fedora::FedoraObject.create(pid, { :label => '', :logMessage => ""})
      Fedora.repository.soap.addRelationship :pid => pid, :relationship => 'info:fedora/fedora-system:def/model#hasModel', :object => "info:fedora/openvault:work", :isLiteral => false, :datatype => nil
      Fedora.repository.soap.addRelationship :pid => pid, :relationship => 'info:fedora/fedora-system:def/relations-external#isDerivationOf', :object => "info:fedora/#{self.pid}", :isLiteral => false, :datatype => nil
      Fedora.repository.soap.addRelationship :pid => pid, :relationship => 'info:fedora/fedora-system:def/relations-external#isMemberOfCollection', :object => "info:fedora/org.mla.openvault", :isLiteral => false, :datatype => nil

      cmodel = nil

      # RELS

      collection = Fedora.repository.sparql 'PREFIX fedora-model: <info:fedora/fedora-system:def/model#>
          PREFIX dc: <http://purl.org/dc/elements/1.1/>
          PREFIX fedora-rels-ext: <info:fedora/fedora-system:def/relations-external#>
          SELECT ?pid ?label
          WHERE {
              {
                { ?pid <info:artesia/link_type#PARENT> <info:fedora/' + self.pid + '> } UNION
              { <info:fedora/' + self.pid + '>  <info:artesia/link_type#CHILD> ?pid }
            }
          }'

      contains.each do |p, label|
        Fedora.repository.soap.addRelationship :pid => pid, :relationship => 'info:fedora/fedora-system:def/relations-external#isMemberOfCollection', :object => p.gsub('uoi-id', 'org.wgbh.mla'), :isLiteral => false, :datatype => nil
      end
      # child/parent -> isMemberOfCollection
      # DC  -- identifier, title, description, type, source, date
      # PBCore  -- from disseminator?
      # Media
      
      # contains/belongs_to -> isPartOf
      #
      contains = Fedora.repository.sparql 'PREFIX fedora-model: <info:fedora/fedora-system:def/model#>
          PREFIX dc: <http://purl.org/dc/elements/1.1/>
          PREFIX fedora-rels-ext: <info:fedora/fedora-system:def/relations-external#>
          SELECT ?pid ?label
          WHERE {
              {
                { ?pid <info:artesia/link_type#BELONGTO> <info:fedora/' + self.pid + '> } UNION
              { <info:fedora/' + self.pid + '>  <info:artesia/link_type#CONTAINS> ?pid } UNION
              { <info:fedora/' + self.pid + '>  <info:artesia/link_type#PLACEDGR> ?pid } UNION
              { ?pid <info:artesia/link_type#PLACEDGROF> <info:fedora/' + self.pid + '>  } UNION
            }
            ?pid <info:fedora/fedora-system:def/model#label> ?label
          }'

      contains.each do |p, label|
        case label
          when /xml/

          when /jpg/

        end
      end
      
      self.doc.xpath
    end

  end
end

