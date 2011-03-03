require_dependency( 'vendor/plugins/blacklight/app/controllers/catalog_controller.rb')
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class CatalogController < ApplicationController
  include Openvault::SolrHelper::DefaultSort
  include Openvault::SolrHelper::BoostMedia
  include Openvault::SolrHelper::Restrictions
  include Openvault::SolrHelper::FacetDomsearch

  def index

    extra_head_content << '<link rel="alternate" type="application/rss+xml" title="RSS for results" href="'+ url_for(params.merge("format" => "rss")) + '">'
    extra_head_content << '<link rel="alternate" type="application/atom+xml" title="Atom for results" href="'+ url_for(params.merge("format" => "atom")) + '">'
    
    (@response, @document_list) = get_search_results
    @filters = params[:f] || []
    respond_to do |format|
      format.html { save_current_search_params }
      format.rss  { render :layout => false }
      format.atom { render :layout => false }
      format.json { render :json => @document_list }
    end
  end

  # displays values and pagination links for a single facet field
  def facet
    @pagination = get_facet_pagination(params[:id], params)
  end

  def embed
    @response, @document = get_solr_response_for_doc_id    
    respond_to do |format|
      format.html {render :layout => 'embed' }
      
      # Add all dynamically added (such as by document extensions)
      # export formats.
      @document.export_formats.each_key do | format_name |
        # It's important that the argument to send be a symbol;
        # if it's a string, it makes Rails unhappy for unclear reasons. 
        format.send(format_name.to_sym) { render :text => @document.export_as(format_name) }
      end
      
    end
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
