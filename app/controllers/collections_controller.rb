class CollectionsController < CatalogController
  include Openvault::SolrHelper::Collections

  def solr_search_params(*args)
    super(*args).merge :per_page => 5000
  end

end
