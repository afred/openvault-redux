module Openvault::SolrHelper
  module DefaultSort
    def self.included(some_class)
    end
 
  def solr_search_params extra_controller_params
    solr_params = super(extra_controller_params)
    solr_params.merge(default_sort_params)
  end

  def default_sort_params
    return {} if params[:sort]
    return { :sort => 'timestamp desc' } if params[:q].blank? and params[:f] and params[:f]['rel_isMemberOfCollection_s'] and params[:f]['rel_isMemberOfCollection_s'].first == 'org.wgbh.mla:pledge'
    return { :sort => 'title_sort asc' } if params[:q].blank? 
    {}
  end
end
end

