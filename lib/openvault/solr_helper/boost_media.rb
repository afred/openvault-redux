module Openvault::SolrHelper
  module BoostMedia
    def self.included(some_class)
      some_class.solr_search_params_logic << :apply_media_bq_params
    end
 
  def apply_media_bq_params solr_parameters, user_parameters
    solr_parameters[:bq] ||= user_parameters[:bq]
    solr_parameters[:bq] ||= ['media_dsid_s:Video^10000','media_dsid_s:Audio^10000','media_dsid_s:Transcript^50000'] 
  end
end
end

