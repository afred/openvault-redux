require_dependency( 'vendor/plugins/blacklight/app/controllers/catalog_controller.rb')
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class CatalogController < ApplicationController
  include Openvault::SolrHelper::DefaultSort
  include Openvault::SolrHelper::Restrictions
  include Openvault::SolrHelper::FacetDomsearch

  # displays values and pagination links for a single facet field
  def facet
    @pagination = get_facet_pagination(params[:id], params)
  end

  # when a request for /catalog/BAD_SOLR_ID is made, this method is executed...
  def invalid_solr_id_error
    response, documents = get_solr_response_for_field_values("pid_s",params[:id])
    redirect_to url_for(:id => documents.first.id) and return if documents.length > 0

    response, documents = get_solr_response_for_field_values("pid_short_s",params[:id])
    redirect_to url_for(:id => documents.first.id) and return if documents.length > 0

    if RAILS_ENV == "development"
      render # will give us the stack trace
    else
      flash[:notice] = "Sorry, you have requested a record that doesn't exist."
      redirect_to root_path, :status => 404
    end
    
  end

end
