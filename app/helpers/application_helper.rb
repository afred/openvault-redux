# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def enforce_rights(doc, action_name)
    case action_name.to_s
    when /media/
      raise Openvault::PermissionDenied if (doc.get("pid_s") =~ /^cbs/ or doc.get("pbcore_pbcorePublisher_distributor_s") =~ /cbs/i) and current_user.nil?
    end
  end


  def datastream_url datastream, options = {}
    "http://openvault.wgbh.org/fedora/get/#{datastream.digital_object.pid}/#{datastream.dsid}"
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
