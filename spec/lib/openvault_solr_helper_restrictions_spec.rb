require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')   

describe Openvault::SolrHelper::Restrictions do
  include Blacklight::SolrHelper
  include Openvault::SolrHelper::Restrictions

  it "should restrict queries to active objects and members of the org.wgbh.openvault collection" do
    self.should_receive(:params).any_number_of_times.and_return({}) 
    h = solr_search_params
    h[:fq].should include('objState_s:A')
    h[:fq].should include('rel_isMemberOfCollection_s:org.wgbh.openvault')
  end
end                                  
