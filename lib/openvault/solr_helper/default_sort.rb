module Openvault::SolrHelper
  module DefaultSort
    def self.included(some_class)
      some_class.solr_search_params_logic += [ :apply_default_sort_params]
    end
 
  def apply_default_sort_params solr_parameters, user_parameters

    solr_parameters[:sort] = "random_#{rand(9999)} asc" if user_parameters[:sort] == 'random'

    if solr_parameters[:sort].blank? or solr_parameters[:sort] == (Blacklight.config[:sort_fields].first || [nil, nil]).last.to_s
      solr_parameters[:sort] = 'title_sort asc' if solr_parameters[:q].blank? 
      solr_parameters[:sort] = 'timestamp desc' if solr_parameters[:q].blank? and solr_parameters[:fq] and solr_parameters[:fq].any? { |x| x =~ /rel_isMemberOfCollection_s/ and x =~ /org.wgbh.mla:pledge/}
    end

    solr_parameters
  end
end
end

