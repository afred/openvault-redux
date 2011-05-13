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

      obj = Rubydora.repository.create(pid, { :label => uois['NAME'] })
      ds = obj.datastreams['UOIS']
      ds.content = uois.to_s
      ds.mimeType = 'text/xml'
      ds.save

      ds = obj.datastreams['File']
      ds.controlGroup = 'R'
      ds.dsLabel = uois['NAME']
      ds.dsLocation =  "http://somewhere.in.artesia/#{uois['NAME']}" 
      ds.save

      obj.models << 'info:fedora/fedora-system:def/model#hasModel'

      obj.save

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

      obj = Rubydora.repository.create(new_pid)

      obj.models << "info:fedora/openvault:work"
      obj.derivation_of << self
      obj.memberOfCollection << "info:fedora/wgbh:openvault"

      cmodel = []

      # RELS

      collection = Rubydora.repository.find_by_sparql "
          SELECT ?pid  FROM <#ri>
          WHERE {
              {
                { ?pid <info:artesia/link_type#PARENT> <#{fqpid}> } UNION
              { <#{fqpid}>  <info:artesia/link_type#CHILD> ?pid }
            }
          }"

      collection.each do |p|
        obj.memberOfCollection << p
      end

      # child/parent -> isMemberOfCollection
      # DC  -- identifier, title, description, type, source, date
      #
      ds = obj.datastreams['DC']
      ds.content = Rubydora.repository.dissemination :pid => self.pid, :sdef => 'sdef:METADATA', :method => 'DC'
      ds.mimeType = 'text/xml'
      ds.controlGroup = 'X'
      ds.save

      # PBCore  -- from disseminator?
      ds = obj.datastreams['PBCore']
      ds.content = Rubydora.repository.dissemination :pid => self.pid, :sdef => 'sdef:METADATA', :method => 'PBCore'
      ds.mimeType = 'text/xml'
      ds.controlGroup = 'M'
      ds.save

      if  dsLocation = Openvault::Media.filename_to_url(uois['NAME'])
        ds = obj.datastreams['File']
        ds.controlGroup = 'R'
        ds.dsLocation = dsLocation
        ds.save
      end

      # Media
      ['.mp4'=> 'video/mp4', '.mp3' => 'audio/mp3', '.flv' => 'audio/x-flv', '.jpg' => 'image/jpg'].each do |ext, mime|
        if dsLocation = Openvault::Media.filename_to_url( uois['NAME'].gsub(File.extname(uois['NAME']), ".#{ext}"))
          cmodel << mime.split('/').first
          dsid = mime.sub('/', '.').capitalize
          ds = obj.datastreams[dsid]
          ds.dsLocation = dsLocation
          ds.mimeType = mime
          ds.controlGroup = 'R'
          ds.save

          if ext == '.jpg'
            ds = obj.datastreams['Thumbnail']
            ds.dsLocation = dsLocation
            ds.mimeType = mime
            ds.controlGroup = 'R'
            ds.save
          end
        end
      end
      
      # contains/belongs_to -> isPartOf
      #
      contains = Rubydora.repository.sparql 'PREFIX fedora-model: <info:fedora/fedora-system:def/model#>
          PREFIX dc: <http://purl.org/dc/elements/1.1/>
          PREFIX fedora-rels-ext: <info:fedora/fedora-system:def/relations-external#>
          SELECT ?pid ?label FROM <#ri>
          WHERE {
              {
                { ?pid <info:artesia/link_type#BELONGTO> <info:fedora/' + self.pid + '> } UNION
              { <info:fedora/' + self.pid + '>  <info:artesia/link_type#CONTAINS> ?pid } UNION
              { <info:fedora/' + self.pid + '>  <info:artesia/link_type#PLACEDGR> ?pid } UNION
              { ?pid <info:artesia/link_type#PLACEDGROF> <info:fedora/' + self.pid + '>  }
            }.
            ?pid <info:fedora/fedora-system:def/model#label> ?label
          }'

      contains.each do |row|
        case label
          when /xml/
            cmodel << 'tei'
            dsLocation = Openvault::Media.filename_to_url(row['label'])
            ds = obj.datastreams['Transcript.tei.xml']
            ds.dsLocation = dsLocation
            ds.mimeType = 'text/xml'
            ds.controlGroup = 'R'
            ds.save
          when /jpg/
            dsLocation = Openvault::Media.filename_to_url(row['label'])
            ds = obj.datastreams['Thumbnail']
            ds.dsLocation = dsLocation
            ds.mimeType = 'image/jpg'
            ds.controlGroup = 'R'
            ds.save
        end
      end

      obj.models << "info:fedora/openvault:#{cmodel.join('-').parameterize}" unless cmodel.empty?
    end
  end
end

