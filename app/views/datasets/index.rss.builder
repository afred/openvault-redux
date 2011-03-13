xml.instruct! :xml, :version=>"1.0"
xml.rss(:version=>"2.0") {
        
  xml.channel {
          
    xml.title("Datasets")
    xml.link(datasets_url(params))
    xml.description("Datasets")
    xml.language('en-us')
    @datasets.each do |dataset|
      xml.item do  
        xml.title( dataset.name || dataset.id )
        xml.description dataset.description
        xml.pubDate dataset.created_at.to_s(:rfp822)
        xml.guid url_for(dataset)
        xml.link(url_for(dataset))                                   
        xml.author( dataset.organization.name )
        xml.enclosure({ :url => (request.protocol + request.host_with_port + dataset.attachment.url), :length => dataset.attachment.size, :type => dataset.attachment.content_type })
      end
    end
          
  }
}
