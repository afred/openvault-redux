
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

#    Blacklight.solr.delete_by_query('*:*')
#   Blacklight.solr.commit

    arr = []

    solrdocs = pids.each do |x| 
      next if x['pid'] =~ /asset:/ or x['pid'] =~ /thumbnail:/
	begin
	print "#{x['pid']}\n"
      arr <<  Rubydora.repository.find(x['pid']).to_solr 
	rescue
	  print "ERROR (#{x['pid']}) : " + ($!).inspect + "\n" 
	end
      pbar.inc

      if (arr.length % 15) == 0
        sleep 2
      end
 
      if arr.length > 100 
        Blacklight.solr.add arr.compact
      #  Blacklight.solr.commit
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
    i = 0
      errors = 0
    mapping = dsids.map do |x|
      i += 1
      sleep 1

      begin
        dsid = x['dsid'].gsub('info:fedora/', '')
        headers = Streamly.head "http://localhost:8180/fedora/get/#{dsid}"
        dsLocation = headers.scan(/Location: ([^\r]+)/).flatten.first.gsub('openvault.wgbh.org/media', 'openvault.wgbh.org:8080') 
        pbar.inc
        print [dsid, dsLocation].join("\t") + "\n"
        [dsid, dsLocation]
      rescue  
	sleep 3
	errors += 1
	retry if errors < 2
      errors = 0
	print "ERROR: #{x}.inspect; #{$!.inspect}\n"
	nil
      end
    end.compact

    print mapping.map { |x| x.join("\t") }.join("\n")
    pbar.finish
  end
  

  desc "Ingest Artesia Asset Properties"
  task :ingest => :environment do

    Rails.logger = Logger.new(STDOUT)
    Rails.logger.level = 0

    ### Load the file
    file = ENV['file']

    unless file
      Rails.logger.warning "USAGE: rake openvault:ingest file=[file]"
      exit
    end
    cmodel = 'artesia:assetProperties'
    pid = "wgbh:#{File.basename(file, File.extname(file))}"

    Rails.logger.info "(Re-)creating Fedora object #{pid}, with File datastream containing #{file}"
    
    Rubydora.repository.find(pid).delete rescue nil
    obj = Rubydora::DigitalObject.create(pid)

    obj.models << "info:fedora/#{cmodel}"
    obj.save

    ds = obj['File']
    # ds.content = open(file)
    ds.content = %x[ perl -p -e "s/&amp;#/\&#/g" #{file} | tidy -xml --input-encoding win1252 --output-encoding utf8 -i  ]
    ds.mimeType = 'text/xml'
    ds.save

    Rubydora.repository.find(obj.pid).process!


    #exit
    # TODO
    if collection = ENV['collection']

        Blacklight.solr.delete_by_query "{!raw f=ri_isMemberOf_s}info:fedora/#{obj.pid}"
        pids = Rubydora.repository.sparql("
      SELECT ?pid FROM <#ri> WHERE {
        ?pid <info:fedora/fedora-system:def/relations-external#isMemberOf> <info:fedora/#{obj.pid}> .
        ?pid <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> <info:fedora/wgbh:openvault>                              
      }").map { |x| x['pid'] }.compact.map { |x| x.strip }

    pids.each { |pid| Rubydora.repository.add_relationship :subject => pid, :predicate => "info:fedora/fedora-system:def/relations-external#isMemberOfCollection", :object => "info:fedora/#{collection}" }

    Blacklight.solr.add pids.map { |pid| Rubydora.repository.find(pid).to_solr }
    Blacklight.solr.commit
    end
 
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
