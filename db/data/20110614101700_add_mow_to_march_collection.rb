class AddMowToMarchCollection < ActiveRecord::Migration
  def self.up
    obj = Rubydora.repository.find('info:fedora/org.wgbh.mla:27afb5495dec3586bbcb00e19f6c2841745a248d')
    obj.memberOfCollection << "info:fedora/org.wgbh.mla:march"
  end

  def self.down

  end
end
