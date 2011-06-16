# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def application_name
    "WGBH Open Vault"
  end

  def extra_body_classes
    extra = []
    extra += ['blacklight-' + controller.class.superclass.controller_name, 'blacklight-' + [controller.class.superclass.controller_name, controller.action_name].join('-')] # if self.class.superclass == CatalogController
    super + extra
  end

  def render_search_context_options
    case 
      when params[:f]
      render :partial => 'catalog/search_context' 

      when (@document and @document.get(:objModels_s).include? "info:fedora/wgbh:COLLECTION")
        render :partial => 'catalog/search_context_collection' 
    end

  end

  def render_document_partial(doc, action_name)
    format = self.send "document_#{action_name}_partial_name", doc if self.respond_to? "document_#{action_name}_partial_name"
    format ||= document_partial_name(doc)
    begin
      enforce_rights(doc, action_name) 
      render :partial=>"catalog/_#{action_name}_partials/#{format}", :locals=>{:document=>doc}
    rescue Openvault::PermissionDenied
      render :partial=>"catalog/_#{action_name}_partials/permission_denied", :locals=>{:document=>doc}
    rescue ActionView::MissingTemplate
      render :partial=>"catalog/_#{action_name}_partials/default", :locals=>{:document=>doc}
    end
  end

  def enforce_rights(doc, action_name)
    case action_name.to_s
    when /media/
      raise Openvault::PermissionDenied if doc.get("pid_s") =~ /^cbs/ and current_user.nil?
    end
  end

  def document_heading
    super.to_s.html_safe
  end

  def render_document_heading(document=@document, options={})
    render :partial => 'document_heading', :locals => { :document => document, :heading => document_heading }
  end

  def link_to_document(doc, opts={:label=>Blacklight.config[:index][:show_link].to_sym, :counter => nil, :results_view => true})
    label = render_document_index_label(doc, opts)
    return link_to(widont(label).html_safe, collection_path(doc[:id])) if doc[:format] == "collection"
    link_to(widont(label).html_safe, catalog_path(doc[:id]))
  end

  def datastream_url datastream, options = {}
    "#{Rubydora.repository.client.url}/get/#{datastream.digital_object.pid}/#{datastream.dsid}"
  end

  def facet_field_names
    names = super

    unless current_user and current_user.has_role? :admin
      names -= ["objModels_s", "ri_collection_ancestors_s", "format", "timestamp_query"]
    end

    names
  end

  def render_facet_value(facet_solr_field, item, options={})
    (link_to_unless(options[:suppress_link], item.value.html_safe, add_facet_params_and_redirect(facet_solr_field, item.value), :class=>"facet_select label") + "&nbsp;".html_safe + render_facet_count(item.hits)).html_safe
  end

  def render_index_field_value(args) 
    value = super(args)

    if args[:field] and args[:field] == 'dc_description_t' and value.length > 600
      return (truncate(value, :length => 500, :separator => ". ") + " #{((link_to_document(args[:document], :label => 'more') if args[:document]))}").html_safe
    end

    value
  end

  def render_document_show_field_label(*args)
    super(*args).gsub(/:$/, '')
  end

  def render_index_doc_actions(*args)
    nil
  end

  def render_show_doc_actions(*args)
    nil
  end

  def render_field_value value=nil
    value = [value] unless value.is_a? Array
    value = value.collect { |x| x.respond_to?(:force_encoding) ? x.force_encoding("UTF-8") : x}
    return value.join(field_value_separator).html_safe
  end

  # Widon't 2.1 (the update based on Matthew Mullenweg's regular expression)
  # http://www.shauninman.com/archive/2007/01/03/widont_2_1_wordpress_plugin
  #
  # @param [String] text the text to apply Widon't to
  # @return [String] a copy of the text with Widon't applied
  def widont(text)
    text.gsub(/([^\s])\s+([^\s]+)\s*$/, '\1&nbsp;\2')
  end

  def render_wordpress_page_content slug
    Wordpress::Page.find(slug).content.html_safe # rescue nil
  end

  def render_google_analytics_code
    render :partial => 'layouts/google_analytics', :locals => { :tracker_id => GOOGLE_ANALYTICS_TRACKER_ID } if defined?(GOOGLE_ANALYTICS_TRACKER_ID)
  end

  def render_comment_metadata_information comment
    if comment.metadata[:begin] && comment.metadata[:end] && comment.metadata[:begin] != comment.metadata[:end]
      return "[Timecode #{comment.metadata[:begin]}-#{comment.metadata[:end]}]"
    end

    if comment.metadata[:begin]
      return "[Timecode #{comment.metadata[:begin]}]"
    end

    if comment.metadata[:crop]
      return "[Crop]"
    end
  end
  
  
end
