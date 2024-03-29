module MediaHelper
  def render_xml_with_xslt xml, xslt
    require 'open-uri'
    xslt = Nokogiri::XSLT(open(xslt).read)
    xml = Nokogiri::XML(open(xml).read)
    xslt.transform(xml).to_s.html_safe
  end
  def render_tei_transcript source, options = {}
    render_xml_with_xslt(source, "public/xslt/tei2timedtranscript.xsl")
  end
  def render_newsml_transcript source, options = {}
    render_xml_with_xslt(source, "public/xslt/newsml2html.xsl")
  end
  def render_audio_player source, options = {}
    options.symbolize_keys!
    options[:width] ||= 320
    options[:src] = source
    options[:id] ||= source.split('/').last.parameterize 
    options[:preload] ||= 'none'

    html = ''

    html += image_tag options[:poster], :width => options[:width] if options[:poster]
    html += tag("audio", options)

    html += javascript_include_tag('openvault/player.js')

    html.html_safe
  end
  def render_video_player sources, options = {}
    options.symbolize_keys!
  
    options[:poster] &&= path_to_image(options[:poster]) 
    options[:id] ||= ((sources.first if sources.is_a?(Array)) || sources ).split('/').last.parameterize 
    options[:preload] ||= 'none'
  
    if size = options.delete(:size)
      options[:width], options[:height] = size.split("x") if size =~ /^\d+x\d+$/
    end
  
    html = ''

    if sources.is_a?(Array)
        html += content_tag("video", options) do
        sources.map { |source| tag("source", :src => source) }.join.html_safe
      end
    else
      options[:src] = sources
      html += tag("video", options)
    end    

    html += javascript_include_tag('openvault/player.js')

    html.html_safe
  end
end
