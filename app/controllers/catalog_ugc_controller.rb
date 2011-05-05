class CatalogUgcController < CatalogController
  include Openvault::SolrHelper::CatalogUgc

  module CatalogUgc
    def render_document_partial doc, action_name
      str = super(doc, action_name)
      str += render :partial => "catalog_ugc/_#{action_name}_partials/ugc", :locals => { :document => doc }

      str.html_safe
    end
  end

  helper CatalogUgc

end
