# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class CatalogController < ApplicationController
  include Blacklight::SolrHelper
  include Blacklight::Catalog
  include Openvault::SolrHelper::DefaultSort
  include Openvault::SolrHelper::BoostMedia
  include Openvault::SolrHelper::Restrictions
  include Openvault::SolrHelper::FacetDomsearch

  before_filter :handle_search_start_over, :only => :index

  def handle_search_start_over
    if params[:search_context] == "all"
      redirect_to catalog_index_url params.slice(:q, :search_field)
    end
  end

  def index
    delete_or_assign_search_session_params

    @search_context = 'result' if view_context.has_search_parameters?
    extra_head_content << view_context.auto_discovery_link_tag(:rss, url_for(params.merge(:format => 'rss')), :title => "RSS for results")
    extra_head_content << view_context.auto_discovery_link_tag(:atom, url_for(params.merge(:format => 'atom')), :title => "Atom for results")
    extra_head_content << view_context.auto_discovery_link_tag(:unapi, unapi_url, {:type => 'application/xml',  :rel => 'unapi-server', :title => 'unAPI' })

    (@response, @document_list) = get_search_results
    @filters = params[:f] || []
    search_session[:total] = @response.total unless @response.nil?

    respond_to do |format|
      format.html { save_current_search_params }
      format.rss  { render :layout => false }
      format.atom { render :layout => false }
      format.json { render :json => @document_list }
    end
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

  def tag
    @response, @document = get_solr_response_for_doc_id
    @document.tag_list = (@document.tag_list + params[:tags].split(",").map(&:strip)).uniq
    @document.save

    respond_to do |format|
      format.html { redirect_to catalog_url(:id => @document.id) }
      format.json { render :json => @document.tags }
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
