class UserGeneratedContentController < CatalogController
  self.solr_search_params_logic = self.solr_search_params_logic.dup
  include BlacklightUserGeneratedContent::SolrHelper::Scope
  module Helper
    def document_partial_name *args
      'ugc'
    end
  end

  helper Helper
end
