module Openvault::SolrHelper::Restrictions
  def self.included(some_class)
    some_class.solr_search_params_logic << :apply_authorization_params
  end

  def apply_authorization_params solr_parameters, user_parameters

    solr_parameters[:fq] ||= []

    solr_parameters[:fq] << "objState_s:A"
    solr_parameters[:fq] << "rel_isMemberOfCollection_s:wgbh\\:openvault"

    solr_parameters
  end

end
