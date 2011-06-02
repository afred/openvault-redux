if defined?(Footnotes) && Rails.env.development? #&& defined?(Rails::Server)
  Footnotes::Filter.notes -= [:cookies]
  Footnotes.run!
   Footnotes::Filter.prefix = 'mvim://open?url=file://%s&amp;line=%d&amp;column=%d'
end
