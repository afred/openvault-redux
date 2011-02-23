module Openvault::SolrHelper::FacetDomsearch
  def solr_facet_params(facet_field, extra_controller_params={})
    solr_params = super(facet_field, extra_controller_params={})
    solr_params[:"f.#{facet_field}.facet.limit"] = 1000
    solr_params
  end
end
