class FixCaseSensitiveFilenames < ActiveRecord::Migration
  def self.up

    Dir.chdir('hydra-jetty/fedora/default/data') do
    %x[ mv ./objects/series/org.wgbh.mla_Vietnam ./objects/series/org.wgbh.mla_vietnam ]

    # %x[ find hydra-jetty/fedora/default/data/objects -exec grep ":Vietnam" -l {} \; | xargs perl -pi -e "s/:Vietnam/:vietnam/g" ]

    %x[ mv ./datastreams/ov1/org.wgbh.mla_Vietnam+PBCore+PBCore.0 ./datastreams/ov1/org.wgbh.mla_vietnam+PBCore+PBCore.0 ]
    %x[ mv ./datastreams/ov1/org.wgbh.mla_NTW+PBCore+PBCore.0 ./datastreams/ov1/org.wgbh.mla_ntw+PBCore+PBCore.0      ]
    %x[ mv ./datastreams/ov1/org.wgbh.mla_TOCN+PBCore+PBCore.0 ./datastreams/ov1/org.wgbh.mla_tocn+PBCore+PBCore.0     ]
    %x[ mv ./datastreams/ov1/org.wgbh.mla_PRPE+PBCore+PBCore.0 ./datastreams/ov1/org.wgbh.mla_prpe+PBCore+PBCore.0      ]
    %x[ mv ./datastreams/ov1/org.wgbh.mla_PRPE+PBCore+PBCore.1 ./datastreams/ov1/org.wgbh.mla_prpe+PBCore+PBCore.1       ]
    end
  end

  def self.down
   # raise IrreversibleMigration
  end
end
