
namespace :openvault do
  desc "Index"
  task :index => :environment do
    require 'progressbar'
      pids = Fedora.repository.sparql("SELECT ?pid FROM <#ri> WHERE {
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
                                      FILTER (?object = <info:fedora/wgbh:openvault>) }")

    pids.shift

    pbar = ProgressBar.new("indexing", pids.length)

    solrdocs = pids.flatten.map { |pid| pid.gsub('info:fedora/', '') }.map do |pid| 
      pbar.inc
      Fedora::FedoraObject.find(pid).to_solr rescue nil
    end

    Blacklight.solr.add solrdocs.compact
    Blacklight.solr.commit

    pbar.finish

  end
end
