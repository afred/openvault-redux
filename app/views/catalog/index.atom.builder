require 'base64'
page_info = paginate_params(@response)

xml.instruct!(:xml, :encoding => "UTF-8")

xml.feed("xmlns" => "http://www.w3.org/2005/Atom",
         "xmlns:opensearch"=>"http://a9.com/-/spec/opensearch/1.1/") do

  xml.title   application_name + " Search Results"
  # an author is required, so we'll just use the app name
  xml.author { xml.name application_name }
  
  xml.link    "rel" => "self", "href" => url_for(params.merge(:only_path => false))
  xml.link    "rel" => "alternate", "href" => url_for(params.merge(:only_path => false, :format => "html")), "type" => "text/html"
  xml.id      url_for(params.merge(:only_path => false, :format => "html", :content_format => nil, "type" => "text/html"))

  # Navigational and context links
  
  xml.link( "rel" => "next", 
            "href" => url_for(params.merge(:only_path => false, :page => (page_info.current_page + 1).to_s))
           ) if  page_info.num_pages > page_info.current_page
  
  xml.link( "rel" => "previous", 
            "href" => url_for(params.merge(:only_path => false, :page => (page_info.current_page - 1).to_s))
           ) if page_info.current_page > 1
           
  xml.link( "rel" => "first", 
            "href" => url_for(params.merge(:only_path => false, :page => "1")))
  
  xml.link( "rel" => "last",
            "href" => url_for(params.merge(:only_path => false, :page => page_info.num_pages.to_s)))
  
  # "search" doesn't seem to actually be legal, but is very common, and
  # used as an example in opensearch docs
  xml.link( "rel" => "search",
            "type" => "application/opensearchdescription+xml",
            "href" =>  url_for(:controller=>'catalog',:action => 'opensearch', :format => 'xml', :only_path => false))

  # opensearch response elements
  xml.opensearch :totalResults, @response.total.to_s
  xml.opensearch :startIndex, @response.start.to_s
  xml.opensearch :itemsPerPage, page_info.limit_value
  xml.opensearch :Query, :role => "request", :searchTerms => params[:q], :startPage => page_info.current_page
  
  
  # updated is required, for now we'll just set it to now, sorry
  xml.updated Time.now.strftime("%Y-%m-%dT%H:%M:%SZ")
  
  @document_list.each do |doc|
    xml.entry do
      xml.title   doc.to_semantic_values[:title][0] || doc[:id]

      # updated is required, for now we'll just set it to now, sorry
      xml.updated Time.now.strftime("%Y-%m-%dT%H:%M:%SZ")
      
      xml.link    "rel" => "alternate", "type" => "text/html", "href" => catalog_url(doc[:id])
      # add other doc-specific formats, atom only lets us have one per
      # content type, so the first one in the list wins.
      xml << render_link_rel_alternates(doc, :unique => true)      
      
      xml.id      catalog_url(doc[:id])
      
      
      if doc.to_semantic_values[:author][0]   
        xml.author { xml.name(doc.to_semantic_values[:author][0]) }
      end
      
      with_format("html") do
        xml.summary "type" => "html" do
	            xml.text! render_document_partial(doc, :index)           
        end
      end
      
      #If they asked for a format, give it to them. 
      if (params["content_format"] &&
          doc.export_formats[params["content_format"].to_sym])
          type = doc.export_formats[params["content_format"].to_sym][:content_type]
          
          case
          when(doc.respond_to?("export_as_#{params["content_format"]}_with_redirect"))
            xml.content :type => type, :src => doc.send("export_as_#{params["content_format"]}_with_redirect")
          else
          
          xml.content :type => type do |content_element|
            data = doc.export_as(params["content_format"])
                    
            # encode properly. See:
            # http://tools.ietf.org/html/rfc4287#section-4.1.3.3
            type = type.downcase
            if (type.downcase =~ /\+|\/xml$/)
              # xml, just put it right in              
              content_element << data
            elsif (type.downcase =~ /text\//)
              # text, escape
              content_element.text! data
            else
              #something else, base64 encode it
              content_element << Base64.encode64(data)
            end
          end
         end
          
      end

      
    end
  end

end





