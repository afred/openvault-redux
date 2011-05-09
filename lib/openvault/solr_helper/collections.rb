module Openvault::SolrHelper::Collections
    def self.included(some_class)
      some_class.solr_search_params_logic << :restrict_to_collections
    end

    def restrict_to_collections solr_parameters, user_parameters
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "dc_type_s:(Collection OR Series)"
      solr_parameters[:sort] = "format asc, #{solr_parameters[:sort]}"

      solr_parameters[:rows] = 500
    end
end
