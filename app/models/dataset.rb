class Dataset < ActiveRecord::Base
  belongs_to :user

  has_attached_file :attachment

  def process!
    obj = Rubydora.repository.find(pid)
    obj = Rubydora.repository.create(pid, { :label => metadata['description'], :logMessage => ""}) if obj.new?
    ds = obj.datastreams['File']

    ds.content = %x[ perl -p -e "s/&amp;#/\&#/g" #{attachment.path} | tidy -xml --input-encoding win1252 --output-encoding utf8 -i  ]
    ds.mimeType = 'text/xml'

    ds.save

    obj.models << 'info:fedora/artesia:assetProperties'
    obj.save

    obj = Rubydora.repository.find(pid)
    

    obj.process!

    self.status = 'ingested'
    self.save
  end
  
  def metadata
    doc = Nokogiri::XML(open(attachment.path))
    metadata = Hash[*doc.xpath('//TEAMS_ASSET_FILE[1]').children.find_all { |x| x.comment? }.first.text.scan(/ (\S+)="([^"]+)"/).flatten]
  end

  def name
    metadata['name'] || title
  end

  def pid
    "teams-asset-file:#{name.parameterize}"
  end

  def collection= collection
    Blacklight.solr.delete_by_query "{!raw f=ri_isMemberOf_s}info:fedora/#{self.pid}"


    pids = Rubydora.repository.sparql("
      SELECT ?pid FROM <#ri> WHERE {
        ?pid <info:fedora/fedora-system:def/relations-external#isMemberOf> <info:fedora/#{self.pid}> .
        ?pid <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> <info:fedora/wgbh:openvault>                              
      }").map { |x| x['pid'] }.compact.map { |x| x.strip }

    pids.each { |pid| Rubydora.repository.add_relationship :subject => pid, :predicate => "info:fedora/fedora-system:def/relations-external#isMemberOfCollection", :object => collection }

    Blacklight.solr.add pids.map { |pid| Rubydora.repository.find(pid).to_solr }
    Blacklight.solr.commit
  end
end
