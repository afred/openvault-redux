
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

      objs =  Rubydora.repository.find_by_sparql(sparql) 

    pbar = ProgressBar.new("indexing", objs.length)

   solrdocs = objs.map { |x| pbar.inc; x.to_solr rescue nil }

    Blacklight.solr.add solrdocs.compact
    Blacklight.solr.commit

    pbar.finish

  end
end
