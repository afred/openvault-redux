require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')   

describe Openvault::SolrHelper::FacetDomsearch do
  include Blacklight::SolrHelper
  include Openvault::SolrHelper::FacetDomsearch

  it "should try to request 'all' the facets (for client-side sorting)" do
    self.should_receive(:params).any_number_of_times.and_return({}) 
    h = solr_facet_params("field")
    h.should be_a_kind_of(Hash)
    h[:"f.field.facet.limit"].should == 1000
  end
end
