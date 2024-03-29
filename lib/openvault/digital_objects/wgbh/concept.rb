module Openvault::DigitalObjects::Wgbh
   module Concept
     def self.extended(document)
       document.solr_mapping_logic << :openvault_metadata_for_solr
       document.solr_mapping_logic << :openvault_user_generated_content_for_solr
     end

     def openvault_metadata_for_solr(doc = {})
       doc['media_dsid_s'] = doc['disseminates_s']
       doc['media_dsid_s'].uniq!

       doc['merlot_s'] = doc['dc_subject_s'].map { |x| x.split(/\s*--\s*/).inject([]) { |sum, item| sum << [sum.last, item].join("/")} }.flatten.uniq.map { |x| "#{x.count("/")}#{x}" } rescue []

       doc['dc_type_s'] ||= []

       format = []
       format << 'video' if doc['media_dsid_s'].any? { |x| x =~ /video/i }
       format << 'audio' if doc['media_dsid_s'].any? { |x| x =~ /audio/i }
       format << 'tei' if doc['media_dsid_s'].any? { |x| x =~ /tei/i }
       format << 'newsml' if doc['media_dsid_s'].any? { |x| x =~ /newsml/i }

       format = ['collection'] if doc['objModels_s'].any? { |x| x =~ /collection/i } or doc['dc_type_s'].any? { |x| x =~ /collection/i }
       format = ['subcollection'] if doc['objModels_s'].any? { |x| x =~ /subcollection/i } or doc['dc_type_s'].any? { |x| x =~ /subcollection/i }
       format = ['series'] if doc['objModels_s'].any? { |x| x =~ /series/i } or doc['dc_type_s'].any? { |x| x =~ /series/i }
       format << 'image' if format.empty? and doc['media_dsid_s'].any? { |x| x =~ /image/i }

       doc['media_s'] ||= []
       doc['media_s'] << 'Video' if doc['media_dsid_s'].any? { |x| x =~ /video/i } 
       doc['media_s'] << 'Audio' if doc['media_dsid_s'].any? { |x| x =~ /audio/i } 
       doc['media_s'] << 'Transcript' if doc['media_dsid_s'].any? { |x| x =~ /tei/i } 
       doc['media_s'] << 'Log' if doc['media_dsid_s'].any? { |x| x =~ /newsml/i } 
       doc['media_s'] << 'Image' if doc['media_s'].empty? and doc['media_dsid_s'].any? { |x| x =~ /image/i } 


       doc['format'] = format.join("_")  


       doc['merlot_s'] = doc['merlot_s'].map do |x|
           arr = []
            z = x.split('--')
             arr << z.shift
              z.each { |x| arr << [arr.last.to_s, x.strip].join(" -- ") }
               arr
       end.flatten.uniq if doc['merlot_s'] 

       doc['title_display'] = doc['title_s']
       doc['title_sort'] = doc['title_s']

       doc['pbcore_pbcoreTitle_program_s'] = (doc['pbcore_pbcoreTitle_series_s'].first + " / " + doc['pbcore_pbcoreTitle_program_s'].first ) unless doc['pbcore_pbcoreTitle_series_s'].blank? or doc['pbcore_pbcoreTitle_program_s'].blank?

       doc['ri_collection_ancestors_s'] = Rubydora.repository.sparql("SELECT ?collection ?collection2 ?collection3 ?collection4 FROM <#ri> WHERE {
       <#{uri}> <fedora-rels-ext:isMemberOfCollection> ?collection .
OPTIONAL {  ?collection <fedora-rels-ext:isMemberOfCollection> ?collection2 . }
OPTIONAL {  ?collection2 <fedora-rels-ext:isMemberOfCollection> ?collection3 . }
OPTIONAL {  ?collection3 <fedora-rels-ext:isMemberOfCollection> ?collection4 . }
       }").map(&:fields).flatten.uniq.reject { |x| x == "null" } 

       prefix = doc['pid_s'].split(':').last
       prefix = prefix.slice(-6, 6) if prefix.length > 10 

       doc['pid_short_s'] = prefix.parameterize.gsub('_', '').to_s 

       collection_prefix_s = doc['ri_collection_ancestors_s'].map { |x| Blacklight.config[:collection_prefix_map][x] }.compact.first

       doc['id'] = "#{doc['pid_short_s']}-#{doc['slug_s'].slice(0,100)}" unless doc['slug_s'].blank? 
       doc['id'] = "#{collection_prefix_s}-#{doc['id']}" if collection_prefix_s
     end

     def openvault_user_generated_content_for_solr(doc = {})
       solr_document = SolrDocument.new(doc)

       doc['tags_s'] = solr_document.tags.map { |x| x.name }.uniq
       doc['tags_by_user_ids_s'] = solr_document.taggings.select { |x| x.tagger_id }.map { |x| "_#{x.tagger_id}/#{x.tag.name}" }
       doc['tags_user_ids_i'] = solr_document.taggings.map { |x| x.tagger_id }.uniq

       doc['comments_public_b'] = solr_document.comments.where(:public => 1).length > 0
       doc['comments_t'] = solr_document.comments.map { |x| x.comment }
       doc['comments_ids_i'] = solr_document.comments.map { |x| x.id }
       doc['comments_user_ids_i'] = solr_document.comments.map { |x| x.user_id }.compact
     end
   end
end
