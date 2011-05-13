module Artesia
  module TeamsAssetFile 
    def self.create dataset, pid = nil
      pid ||= dataset.pid

      obj = Rubydora.repository.find(pid)
      obj ||= Rubydora.repository.create(pid, { :label => dataset.metadata['description'], :logMessage => ""})
      ds = obj.datastreams['File']
      ds.content = %x[ tidy -xml -i -n #{dataset.attachment.path} ]
      ds.mimeType = 'text/xml'

      ds.save

      obj.models << 'info:fedora/artesia:assetProperties'
      obj.save

      Rubydora.repository.find(pid)
    end
  end
end
