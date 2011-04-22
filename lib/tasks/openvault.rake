
namespace :openvault do
  desc "Index"
  task :index => :environment do
    require 'progressbar'
      sparql = "SELECT ?pid FROM <#ri> WHERE {
                                          {
  ?pid <fedora-rels-ext:isMemberOfCollection> ?object
} UNION {
?pid <fedora-rels-ext:isMemberOfCollection> ?parent.
?parent <fedora-rels-ext:isMemberOfCollection> ?object
} UNION {
?pid <fedora-rels-ext:isMemberOfCollection> ?parent.
?parent <fedora-rels-ext:isMemberOfCollection> ?parent2.
?parent2 <fedora-rels-ext:isMemberOfCollection> ?object
}
                                      FILTER (?object = <info:fedora/wgbh:openvault>) }"

      pids =  Rubydora.repository.sparql(sparql) 

    pbar = ProgressBar.new("indexing", pids.length)

    Blacklight.solr.delete_by_query('*:*')
    Blacklight.solr.commit
    solrdocs = pids.each_slice(100) do |d| 
      Blacklight.solr.add d.map { |x| pbar.inc; Rubydora.repository.find(x['pid']).to_solr rescue nil }.compact
      Blacklight.solr.commit
    end 
    Blacklight.solr.optimize

    pbar.finish
  end

  desc "Ingest Artesia Asset Properties"
  task :ingest => :environment do

    ### Load the file
    file = ENV['file']
    cmodel = 'artesia:assetProperties'
    pid = "wgbh/#{File.basename(file, File.extname(file))}"
    obj = Rubydora::DigitalObject.create(pid)

    obj.models << "info:fedora/#{cmodel}"
    obj = obj.save

    ds = obj['File']
    ds.file = open(file)
    ds.mimeType = 'text/xml'
    ds.save

    obj.process!
  end
end
