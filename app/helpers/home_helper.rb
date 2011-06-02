module HomeHelper
  def image_sprite sprite, document
    offset = sprite[document]
    unless extra_head_content.any? { |x| x =~ /sprite-#{sprite.name}/ }
      extra_head_content << "<style type='text/css'> .sprite-#{sprite.name} { height: #{sprite.options[:height]}px; width: #{sprite.options[:width]}px; display: inline-block; background-image: url(#{image_path("sprites/#{sprite.name}.jpg")}); background-repeat: no-repeat; text-indent: -9999px; position: relative; } </style>"
    end
    content_tag :span, document.get(:title_display), :class => "sprite-#{sprite.name}", :style =>"background-position: -#{offset[:x]}px -#{offset[:y]}px; ", :title => document.get(:title_display) 
  end

end
