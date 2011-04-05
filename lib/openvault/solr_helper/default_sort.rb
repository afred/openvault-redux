module Openvault::SolrHelper
  module DefaultSort
    def self.included(some_class)
    end
 
  def solr_search_params extra_controller_params = {}
    solr_params = super(extra_controller_params)
    apply_default_sort_params(solr_params)
  end

  def apply_default_sort_params solr_params

    solr_params[:sort] = "random_#{rand(9999)} asc" if solr_params[:sort] == 'random'

    solr_params[:sort] ||= 'timestamp desc' if solr_params[:q].blank? and solr_params[:fq] and solr_params[:fq].any? { |x| x =~ /rel_isMemberOfCollection_s/ and x =~ /org.wgbh.mla:pledge/}
    solr_params[:sort] ||= 'title_sort asc' if solr_params[:q].blank?

    solr_params
  end
end
end

