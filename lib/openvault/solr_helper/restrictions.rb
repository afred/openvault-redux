module Openvault::SolrHelper::Restrictions
  def self.included(some_class)

  end

  def solr_search_params(extra_controller_params = {})
    solr_params = super(extra_controller_params)
    apply_authorization_params(solr_params)
  end

  def apply_authorization_params solr_params

    solr_params[:fq] ||= []

    solr_params[:fq] << "objState_s:A"
    solr_params[:fq] << "rel_isMemberOfCollection_s:org.wgbh.openvault"

    solr_params
  end

end
