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

    def publish pid
      return unless validate_datastreams
      publish!
    end

    def publish! pid
      obj = Fedora::FedoraObject.create(pid, { :label => '', :logMessage => ""})
      Fedora.repository.soap.addRelationship :pid => pid, :relationship => 'info:fedora/fedora-system:def/model#hasModel', :object => "info:fedora/openvault:concept", :isLiteral => false, :datatype => nil
      Fedora.repository.soap.addRelationship :pid => pid, :relationship => 'info:fedora/fedora-system:def/relations-external#isDerivationOf', :object => "info:fedora/#{self.pid}", :isLiteral => false, :datatype => nil
      Fedora.repository.soap.addRelationship :pid => pid, :relationship => 'info:fedora/fedora-system:def/relations-external#isMemberOfCollection', :object => "info:fedora/org.mla.openvault", :isLiteral => false, :datatype => nil





    end

  end
end

