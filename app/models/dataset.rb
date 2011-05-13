class Dataset < ActiveRecord::Base
  belongs_to :user

  has_attached_file :attachment

  def process!
    obj = Artesia::TeamsAssetFile.create(self)

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
end
