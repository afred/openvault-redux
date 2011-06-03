module Openvault::SolrHelper::CatalogUgc
    def self.included(some_class)
      some_class.solr_search_params_logic << :restrict_to_records_with_comments
    end

    def restrict_to_records_with_comments solr_parameters, user_parameters
      solr_parameters[:fq] ||= []
      if current_user
        if current_user.has_role? :admin and user_params[:all]
          solr_parameters[:fq] << "comments_ids_i:[* TO *]"
        else
          solr_parameters[:fq] << "comments_user_ids_i:#{current_user.id} OR tags_user_ids_i:#{current_user.id}"
        end
      else
        solr_parameters[:fq] << "comments_public_b:true"
      end
    end
end
