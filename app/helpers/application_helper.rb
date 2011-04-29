# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def application_name
    "WGBH Open Vault"
  end

  def render_document_partial(doc, action_name)
    format = self.send "document_#{action_name}_partial_name", doc if self.respond_to? "document_#{action_name}_partial_name"
    format ||= document_partial_name(doc)
    begin
      enforce_rights(doc, action_name) if action_name == "media"
      render :partial=>"catalog/_#{action_name}_partials/#{format}", :locals=>{:document=>doc}
    rescue Openvault::PermissionDenied
      render :partial=>"catalog/_#{action_name}_partials/permission_denied", :locals=>{:document=>doc}
    rescue ActionView::MissingTemplate
      render :partial=>"catalog/_#{action_name}_partials/default", :locals=>{:document=>doc}
    end
  end

  def enforce_rights(doc, action_name)
    case action_name.to_s
    when /(show|embed)/
      raise Openvault::PermissionDenied if doc.get("pid_s") =~ /^cbs/ and current_user.nil?
    end
  end

  def render_document_heading(document=@document, options={})
    render :partial => 'document_heading', :locals => { :document => document, :heading => document_heading }
  end

  def link_to_document(doc, opts={:label=>Blacklight.config[:index][:show_link].to_sym, :counter => nil, :results_view => true})
    label = render_document_index_label doc, opts
    return link_to(label.html_safe, catalog_path(doc[:id]))
  end

  def datastream_url datastream, options = {}
    "http://localhost:8180/fedora/get/#{datastream.digital_object.pid}/#{datastream.dsid}"
  end

  def render_facet_value(facet_solr_field, item, options={})
    (link_to_unless(options[:suppress_link], item.value.html_safe, add_facet_params_and_redirect(facet_solr_field, item.value), :class=>"facet_select label") + " " + render_facet_count(item.hits)).html_safe
  end

  def render_field_value value
    value = [value] unless value.is_a? Array
    value.compact.map { |v| v.gsub(/<resource_link res="([^"]+)">([^<]+)<\/resource_link>/) { |match| link_to $2, catalog_url("org.wgbh.mla\:#{$1}") } }.join(field_value_separator).html_safe
  end

  def render_document_show_field_label(*args)
    super(*args).gsub(/:$/, '')
  end
end
