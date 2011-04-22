module Openvault::DigitalObjects::Artesia
  module AssetProperties
     def self.extended(document)
     end

     def process!

       assetProperties.xpath('//UOIS').map do |uois|
         obj = Rubydora.create("org.wgbh.mla:#{uois['UOI_ID']}") 

         ds = obj['DAMXML']
         ds.content = uois.to_s
         ds.mimeType = 'text/xml'
         ds.save

         obj = obj.save  
       end.tap do |obj|
         assetProperties_links.select { |x| x[:subject] == obj.pid.split(":").first }.each do |link|
           add_relationship(link[:predicate], link[:object])
         end
       end.map do |obj|
         ds = obj['DC']
         ds.content = ''
         ds.mimeType = 'text/xml'
         ds.save

         ds = obj['PBCore']
         ds.content = ''
         ds.mimeType = 'text/xml'
         ds.save
       end.map do |obj|

       end
     end

     def assetProperties dsid = 'File'
       file = datastream[dsds].content
       # processing?
       @assetProperties ||= Nokogiri::XML(file)
     end

     def assetProperties_links
       return @assetProperties_links if @assetProperties_links
       entities = Hash[@doc.internal_subset.children.map { |x| [x.name, x.system_id.split(":").last ] }]
       
       @assetProperties_links ||= assetProperties.xpath('//LINK').map do |link|
         predicate = "info:wgbh/artesia:relations##{link['LINK_TYPE']}"
         subject = "org.wgbh.mla:#{entities[link['SOURCE']]}"
         object = "org.wgbh.mla:#{entities[link['DESTINATION']]}"

         { :subject => subject, :predicate => predicate, :object => object }
       end.map do |link|
         predicate = case link[:predicate].split("#").last
                       when "PARENT" then "CHILD"
                       when "CHILD" then "PARENT"
                       when "CONTAINS" then "BELONGTO"
                       when "BELONGTO" then "CONTAINS"
                       when "PLACEDGR" then "ARTESIA.LINKTYPE.ISPLACEDGROF"
                       when "ARTESIA.LINKTYPE.ISPLACEDGROF" then "PLACEDGR"
                       else
                     end

         next link if predicate.blank?

         rev = { :subject => link[:object], :predicate => predicate, :object => link[:subject] }
         [link, rev]
       end.flatten.uniq
     end
  end
end
