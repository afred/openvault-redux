class ApplicationController < ActionController::Base
   helper_method :stored_location_for
  # Adds a few additional behaviors into the application controller 
   include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 

  protect_from_forgery
  def default_html_head

    stylesheet_links << ['jquery/ui-lightness/jquery-ui-1.8.1.custom.css',  {:plugin=>:blacklight, :media=>'all'}]
    stylesheet_links << ["compiled/screen", { :media => 'screen, projection' }]
    stylesheet_links << ["compiled/print", { :media => 'print' }]

    # js is included by jammit from config/assets.yml
    javascript_includes = []
    # javascript_includes << ['jquery.min.js','jquery-ui-1.8.1.custom.min.js', 'rails.js', 'jquery.uiext.ajaxydialog.js']
    # javascript_includes << [ 'blacklight' ]
    # javascript_includes << ["jquery.highlight.js", "jquery.scrollTo.js", "swfobject.js", "jwplayer.js", "application"]
    
    extra_head_content << ('<!--[if IE]>' + view_context.javascript_include_tag("flot/excanvas.min.js") + '<![endif]-->').html_safe  

  end   

  def choose_layout
    'application' unless request.xml_http_request? || ! params[:no_layout].blank?
  end     

  def authenticate_admin_user! *args
    authenticate_user!(*args)
    raise "Unauthorized" unless current_user && current_user.has_role?(:admin)
  end  

  private 
  ##
  # Returns a local URL path component to redirect to after login. 
  # Will be taken from referer query param or referer HTTP header, in that
  # order, but only used if allowable non-blacklisted internal URL, otherwise
  # root_path is used.    
  #
  # `redirect_path` performs some basic checks to ensure the URL is internal
  #  and will not cause redirect loops.
  def stored_location_for *args
    referer = params[:referer] || request.referer

    if referer && (referer =~ %r|^https?://#{request.host}#{root_path}| ||
      referer =~ %r|^https?://#{request.host}:#{request.port}#{root_path}|)
      #self-referencing absolute url, make it relative
      referer.sub!(%r|^https?://#{request.host}(:#{request.port})?|, '')
    elsif referer && referer =~ %r|^(\w+:)?//|
      referer = nil
    end
    
    if referer && referer_blacklist.any? {|blacklisted| referer.starts_with?(blacklisted)  }
      referer = nil
    elsif referer && referer[0,1] != '/'
      referer = nil
    end

    if referer and request.xhr?
      referer += (referer =~ /\?/ ? "&" : "?")
      referer += "no_layout=true" 
    end
      
    return referer || super(*args)
  end

  ##
  # Returns a list of urls that should /never/ be the redirect target for
  # post_auth_redirect_url. 
  def referer_blacklist
    [new_user_session_path, destroy_user_session_path]
  end
  
end
