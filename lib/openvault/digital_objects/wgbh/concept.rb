module Openvault::DigitalObjects::Wgbh
   module Concept
     def self.extended(document)
       document.solr_mapping_logic << :openvault_metadata_for_solr
       document.solr_mapping_logic << :openvault_user_generated_content_for_solr
     end

     def openvault_metadata_for_solr(doc = {})
       doc['media_dsid_s'] = doc['disseminates_s']
       doc['media_dsid_s'].uniq!

       doc['dc_type_s'] ||= []

       format = []
       format << 'video' if doc['media_dsid_s'].any? { |x| x =~ /video/i }
       format << 'audio' if doc['media_dsid_s'].any? { |x| x =~ /audio/i }
       format << 'image' if doc['media_dsid_s'].any? { |x| x =~ /image/i }
       format << 'tei' if doc['media_dsid_s'].any? { |x| x =~ /tei/i }
       format << 'newsml' if doc['media_dsid_s'].any? { |x| x =~ /newsml/i }

       format = ['collection'] if doc['objModels_s'].any? { |x| x =~ /collection/i } or doc['dc_type_s'].any? { |x| x =~ /collection/i }
       format = ['subcollection'] if doc['objModels_s'].any? { |x| x =~ /subcollection/i } or doc['dc_type_s'].any? { |x| x =~ /subcollection/i }
       format = ['series'] if doc['objModels_s'].any? { |x| x =~ /series/i } or doc['dc_type_s'].any? { |x| x =~ /series/i }

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

       doc['pbcore_pbcoreTitle_program_s'] = (doc['pbcore_pbcoreTitle_series_s'] + " / " + doc['pbcore_pbcoreTitle_program_s'] rescue doc['pbcore_pbcoreTitle_program_s']) if doc['pbcore_pbcoreTitle_series_s'] and  doc['pbcore_pbcoreTitle_program_s'] 

       prefix = doc['pid_s'].split(':').last
       prefix = prefix.slice(-6, 6) if prefix.length > 10 

       doc['pid_short_s'] = prefix.parameterize.gsub('_', '-').to_s 
       doc['id'] = "#{doc['pid_short_s']}-#{doc['slug_s']}" unless doc['slug_s'].blank? 
     end

     def openvault_user_generated_content_for_solr(doc = {})
       doc['tags_s'] = []
       doc['tags_s'] << surrogate.tags.map { |x| x.name }
       doc['tags_s'] << surrogate.taggings.select { |x| x.tagger_id }.map { |x| "_#{x.tagger_id}/#{x.tag.name}" }
       doc['tags_s'] << surrogate.taggings.select { |x| x.tagger_id }.map { |x| "_#{x.tagger_id}" }

       doc['tags_s'].flatten!.uniq
       doc['comments_t'] = surrogate.comments.map { |x| x.comment }
       doc['comments_ids_s'] = surrogate.comments.map { |x| x.id }
       surrogate.tags
     end
   end
end
