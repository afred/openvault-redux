require_dependency 'vendor/plugins/blacklight/app/helpers/application_helper.rb'
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def render_document_partial(doc, action_name)
    format = document_partial_name(doc)
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
    when /(show|embed)/
      raise Openvault::PermissionDenied if doc.get("pid_s") =~ /^cbs/ and current_user.nil?
    end
  end

  def render_document_metadata_partial(document=@document, options={})
    render :partial => 'document_metadata', :locals => { :document => document }
  end

  def render_document_heading(document=@document, options={})
    render :partial => 'document_heading', :locals => { :document => document, :heading => document_heading }
   end
  def link_to_document(doc, opts={:label=>Blacklight.config[:index][:show_link].to_sym, :counter => nil, :results_view => true})
    label = render_document_index_label doc, opts
    return link_to(label, catalog_path(doc[:id]))
  end
end
