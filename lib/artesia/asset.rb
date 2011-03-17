module Artesia
  module Asset
    def self.extended(object)
    end

    def self.create metadata
      el = Nokogiri::XML(metadata)
      uois = el.xpath('//UOIS').first
      uois.xpath('//@*').select { |x| x.name =~ /TYPE$/ or x.name =~ /ROLE$/ }.select { |x| x.value =~ /\d$/ }.each do |attr|
        attr.value = attr.value.gsub(/\d+$/, '')
      end
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

    def uois
      self.doc.root
    end

    def validate_datastreams
    #  validate_datastreams
    end

    def publish
      return unless validate_datastreams
      publish!
    end

    def publish!
      new_pid = self.pid.gsub('uoi-id', 'org.wgbh.mla')

      obj = Fedora::FedoraObject.create(new_pid, { :label => '', :logMessage => ""})
      Fedora.repository.soap.addRelationship :pid => new_pid, :relationship => 'info:fedora/fedora-system:def/model#hasModel', :object => "info:fedora/openvault:work", :isLiteral => false, :datatype => nil
      Fedora.repository.soap.addRelationship :pid => new_pid, :relationship => 'info:fedora/fedora-system:def/relations-external#isDerivationOf', :object => "info:fedora/#{self.pid}", :isLiteral => false, :datatype => nil
      Fedora.repository.soap.addRelationship :pid => new_pid, :relationship => 'info:fedora/fedora-system:def/relations-external#isMemberOfCollection', :object => "info:fedora/org.mla.openvault", :isLiteral => false, :datatype => nil

      cmodel = []

      # RELS

      collection = Fedora.repository.sparql 'PREFIX fedora-model: <info:fedora/fedora-system:def/model#>
          PREFIX dc: <http://purl.org/dc/elements/1.1/>
          PREFIX fedora-rels-ext: <info:fedora/fedora-system:def/relations-external#>
          SELECT ?pid 
          WHERE {
              {
                { ?pid <info:artesia/link_type#PARENT> <info:fedora/' + self.pid + '> } UNION
              { <info:fedora/' + self.pid + '>  <info:artesia/link_type#CHILD> ?pid }
            }
          }'

      collection.shift

      collection.flatten.each do |p|
        Fedora.repository.soap.addRelationship :pid => new_pid, :relationship => 'info:fedora/fedora-system:def/relations-external#isMemberOfCollection', :object => p.gsub('uoi-id', 'org.wgbh.mla'), :isLiteral => false, :datatype => nil
      end
      # child/parent -> isMemberOfCollection
      # DC  -- identifier, title, description, type, source, date
      #
      Fedora.repository.object_url({:pid => self.pid, :datastream => 'sdef:METADATA/DC'})
      Fedora::Datastream.new('DC', {:dsLocation => Fedora.repository.object_url({:pid => self.pid, :datastream => 'sdef:METADATA/DC'}), :mimeType => 'text/xml'}).add(obj.client)

      # PBCore  -- from disseminator?
      Fedora::Datastream.new('PBCore', {:dsLocation => Fedora.repository.object_url({:pid => self.pid, :datastream => 'sdef:METADATA/PBCore'}), :mimeType => 'text/xml'}).add(obj.client)

      if  dsLocation = Openvault::Media.filename_to_url(uois['NAME'])
        Fedora::Datastream.new('File', {:controlGroup => 'R', :dsLocation => dsLocation}).add(obj.client)
      end
      # Media
      ['.mp4'=> 'video/mp4', '.mp3' => 'audio/mp3', '.flv' => 'audio/x-flv', '.jpg' => 'image/jpg'].each do |ext, mime|
        if dsLocation = Openvault::Media.filename_to_url( uois['NAME'].gsub(File.extname(uois['NAME']), ".#{ext}"))
          cmodel << mime.split('/').first
          dsid = mime.sub('/', '.').capitalize
          Fedora::Datastream.new(dsid, {:controlGroup => 'R', :dsLocation => dsLocation, :mimeType => mime}).add(obj.client)
          Fedora::Datastream.new('Thumbnail', {:controlGroup => 'R', :dsLocation => dsLocation, :mimeType => mime}).add(obj.client) if ext == '.jpg'
        end
      end
      
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
              { ?pid <info:artesia/link_type#PLACEDGROF> <info:fedora/' + self.pid + '>  }
            }.
            ?pid <info:fedora/fedora-system:def/model#label> ?label
          }'

      contains.shift

      contains.each do |p, label|
        case label
          when /xml/
            cmodel << 'tei'
            dsLocation = Openvault::Media.filename_to_url(label)
            Fedora::Datastream.new('Transcript.tei.xml', {:controlGroup => 'R',:dsLocation => dsLocation, :mimeType => 'text/xml' }).add(obj.client)
          when /jpg/
            dsLocation = Openvault::Media.filename_to_url(label)
            Fedora::Datastream.new('Thumbnail', {:controlGroup => 'R',:dsLocation => dsLocation, :mimeType => 'image/jpg' }).add(obj.client)
        end
      end

      Fedora.repository.soap.addRelationship :pid => new_pid, :relationship => 'info:fedora/fedora-system:def/model#hasModel', :object => "info:fedora/openvault:#{cmodel.join('-').parameterize}", :isLiteral => false, :datatype => nil unless cmodel.empty?
      
      self.doc.xpath
    end
  end
end

