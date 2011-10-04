module Openvault::SolrHelper::Restrictions
  def self.included(some_class)
    some_class.solr_search_params_logic += [ :apply_authorization_params]
  end

  def apply_authorization_params solr_parameters, user_parameters

    solr_parameters[:fq] ||= []

    unless current_user and current_user.has_role? :admin
      solr_parameters[:fq] << "{!raw f=objState_s}A"
    end

    unless current_user and current_user.has_role? :admin
      solr_parameters[:fq] << "{!raw f=ri_isMemberOfCollection_s}info:fedora/wgbh:openvault"
    end
  end
end
