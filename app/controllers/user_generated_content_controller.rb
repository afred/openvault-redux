class UserGeneratedContentController < CatalogController
  include BlacklightUserGeneratedContent::SolrHelper::Scope
  module Helper
    def document_partial_name *args
      'ugc'
    end
  end

  helper Helper
end
