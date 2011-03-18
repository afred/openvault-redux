module Openvault::SolrHelper::Restrictions
  def self.included(some_class)

  end

  def solr_search_params(extra_controller_params)
    solr_params = super(extra_controller_params)
    solr_params.merge(authorization_params)
  end

  def authorization_params
    return { :phrase_filters => { :objState_s => "A", :rel_isMemberOfCollection_s => "info:fedora/org.wgbh.openvault" } }

  end

end
