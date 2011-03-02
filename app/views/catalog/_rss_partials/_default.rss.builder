xml.title( document.to_semantic_values[:title][0] || document[:id] )                              
xml.link(catalog_url(document[:id]))                                   
xml.author( document.to_semantic_values[:author][0] ) if document.to_semantic_values[:author][0]  

xml.media :thumbnail, :url => image_path(document.thumbnail.url(:style => :preview)), :'xmlns:media' => "http://search.yahoo.com/mrss/"

