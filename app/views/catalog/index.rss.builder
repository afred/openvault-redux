xml.instruct! :xml, :version=>"1.0"
xml.rss(:version=>"2.0") {
        
  xml.channel {
          
    xml.title(application_name + " Search Results")
    xml.link(url_for(params))
    xml.description(application_name + " Search Results")
    xml.language('en-us')
    @document_list.each do |doc|
      xml.item do  
        xml << render_document_partial(doc, 'rss')
      end
    end
          
  }
}
