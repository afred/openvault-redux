module Openvault::SolrHelper
  module BoostMedia
    def self.included(some_class)
    end
 
  def solr_search_params extra_controller_params = {}
    solr_params = super(extra_controller_params)
    apply_media_bq_params(solr_params)
  end

  def apply_media_bq_params solr_params
    solr_params[:bq] ||= ['media_dsid_s:Video^10000','media_dsid_s:Audio^10000','media_dsid_s:Transcript^50000'] 
    solr_params
  end
end
end

