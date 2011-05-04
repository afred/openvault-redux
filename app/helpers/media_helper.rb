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
    html = ''

    html += image_tag options[:poster], :width => options[:width] if options[:poster]
    html += tag("audio", options)

    extra_head_content << <<EOF
<script type="text/javascript">
  $(function() {
      $('audio').one('canplay', function() {
         var start = 0;
         try {
          start = /t=(\\d+)/.exec(location.hash).pop();
         }
         catch(err) {
          start = #{params[:t] || 0};
         }
          if(start > 0) {
            this.currentTime = start;
          }
      });
      });
</script>
EOF

    html.html_safe
  end
  def render_video_player sources, options = {}
    stylesheet_links << ["/mediaelement/build/mediaelementplayer.css"]
    javascript_includes << ["/mediaelement/build/mediaelement-and-player.min.js"]
    extra_head_content << <<EOF
<script type="text/javascript">
  $(function() {
      $('video').mediaelementplayer();
      $('video').one('canplay', function() {
         var start = 0;
         try {
          start = /t=(\\d+)/.exec(location.hash).pop();
         }
         catch(err) {
          start = #{params[:t] || 0};
         }
          if(start > 0) {
            this.currentTime = start;
          }
      });
      });
</script>
EOF

    options.symbolize_keys!
  
    options[:poster] = path_to_image(options[:poster]) if options[:poster]
  
    if size = options.delete(:size)
      options[:width], options[:height] = size.split("x") if size =~ /^\d+x\d+$/
    end
  
    if sources.is_a?(Array)
      content_tag("video", options) do
        sources.map { |source| tag("source", :src => source) }.join.html_safe
      end
    else
      options[:src] = sources
      tag("video", options)
    end    
  end
end
