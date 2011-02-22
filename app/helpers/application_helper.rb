require 'vendor/plugins/blacklight/app/helpers/application_helper.rb'
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def render_document_metadata_partial(document=@document, options={})
    render :partial => 'document_metadata', :locals => { :document => document }
  end

  def render_document_heading(document=@document, options={})
    render :partial => 'document_heading', :locals => { :document => document, :heading => document_heading }
  end
end
