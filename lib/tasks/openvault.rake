
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

    arr = []

    solrdocs = pids.each do |x| 
      arr <<  Rubydora.repository.find(x['pid']).to_solr rescue nil
      pbar.inc

      if arr.length > 100 
        Blacklight.solr.add arr.compact
        arr = []
      end
    end

    Blacklight.solr.commit
    Blacklight.solr.optimize 


    pbar.finish
  end

  desc "Ingest Artesia Asset Properties"
  task :ingest => :environment do

    ### Load the file
    file = ENV['file']
    cmodel = 'artesia:assetProperties'
    pid = "wgbh:#{File.basename(file, File.extname(file))}"
    Rubydora.repository.find(pid).delete rescue nil
    obj = Rubydora::DigitalObject.create(pid)

    obj.models << "info:fedora/#{cmodel}"
    obj.save

    ds = obj['File']
    ds.file = open(file)
    ds.mimeType = 'text/xml'
    ds.save

    Rubydora.repository.find(obj.pid).process!
  end
end
