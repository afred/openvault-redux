
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

  desc "apache map"
  task :rewrite => :environment do
    require 'progressbar'
    sparql = "SELECT ?dsid FROM <#ri> WHERE {
    ?pid <info:fedora/fedora-system:def/view#disseminates> ?dsid .
  {
    ?dsid  <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/Video.mp4>  .
    } UNION {
    ?dsid  <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/Audio.mp3>  .
  }
}"    
    dsids = Rubydora.repository.sparql(sparql)

    pbar = ProgressBar.new("indexing", dsids.length)

    mapping = dsids.map do |x|
    begin
      dsid = x['dsid'].gsub('info:fedora/', '')
      headers = Streamly.head "http://localhost:8180/fedora/get/#{dsid}"
      dsLocation = headers.scan(/Location: ([^\r]+)/).flatten.first.gsub('openvault.wgbh.org/media', 'openvault.wgbh.org:8080') 
      pbar.inc
      print [dsid, dsLocation].join("\t") + "\n"
      [dsid, dsLocation]
      rescue
        nil
      end
    end.compact

    print mapping.map { |x| x.join("\t") }.join("\n")
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

  desc "Pre-render object thumbnails"
  task :bake => :environment do
    require 'progressbar'
    sparql = "SELECT ?pid FROM <#ri> WHERE { ?pid <fedora-rels-ext:isMemberOfCollection> <info:fedora/wgbh:openvault> }"
    pids = Rubydora.repository.sparql(sparql)
    styles = [:preview, :thumbnail]
    pbar = ProgressBar.new("indexing", pids.length)

    pids.each do |p|
      doc = SolrDocument.new :pid_s => p['pid'].gsub('info:fedora/', '')
      styles.each { |s| doc.thumbnail.url :style => s }
      pbar.inc
    end
    pbar.finish
  end
end
