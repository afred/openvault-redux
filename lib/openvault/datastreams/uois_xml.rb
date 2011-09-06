module Openvault::Datastreams
   module UoisXml
     def to_solr solr_doc = {}
      super(solr_doc)

      uois = Nokogiri::XML(content) 

      solr_doc['uoi_id_s'] = uois.xpath('//UOIS/@UOI_ID')

      if category = uois.xpath('//WGBH_TYPE/@ITEM_CATEGORY').first
	solr_doc['uois_item_category_s'] = category.to_s
      end

     end 
   end
end
