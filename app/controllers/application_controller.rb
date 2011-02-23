require_dependency( 'vendor/plugins/blacklight/app/controllers/application_controller.rb')
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  def default_html_head

    stylesheet_links << ["compiled/screen", { :media => 'screen, projection' }]
    stylesheet_links << ["compiled/print", { :media => 'print' }]
    stylesheet_links << ['jquery/ui-lightness/jquery-ui-1.8.1.custom.css',  {:plugin=>:blacklight, :media=>'all'}]
    stylesheet_links << ["application", "openvault"]

    javascript_includes << ['jquery-1.4.2.min.js', 'jquery-ui-1.8.1.custom.min.js',  'application', { :plugin=>:blacklight } ]
    javascript_includes << ['jquery.domsearch.js', 'liquidmetal.js', "application", "openvault"]

  end

end
