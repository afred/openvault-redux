module Openvault::DigitalObjects::Wgbh::Collection
  def self.extended(document)
    document.send(:extend, Openvault::DigitalObjects::Wgbh::Concept)
  end
end
