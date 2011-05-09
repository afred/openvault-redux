class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller 
   include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 

  protect_from_forgery
  def default_html_head

    stylesheet_links << ['jquery/ui-lightness/jquery-ui-1.8.1.custom.css',  {:plugin=>:blacklight, :media=>'all'}]
    stylesheet_links << ["compiled/screen", { :media => 'screen, projection' }]
    stylesheet_links << ["compiled/print", { :media => 'print' }]

    javascript_includes << ['jquery.min.js','jquery-ui-1.8.1.custom.min.js', 'rails.js', 'jquery.uiext.ajaxydialog.js']
    javascript_includes << [ 'blacklight' ]
    javascript_includes << ['jquery.domsearch.js', 'liquidmetal.js', "jquery.highlight.js", "jquery.scrollTo.js", "jquery.hotkeys.js", "jquery.formalize.min.js", "jquery.sausage.js", "swfobject.js", "jwplayer.js", "application"]

  end   

  def choose_layout
    'application' unless request.xml_http_request? || ! params[:no_layout].blank?
  end     
end
