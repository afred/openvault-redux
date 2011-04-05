require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')   

describe Openvault::SolrHelper::DefaultSort do
  include Blacklight::SolrHelper
  include Openvault::SolrHelper::DefaultSort

  it "should sort by title if no query string is provided" do
    self.should_receive(:params).any_number_of_times.and_return({}) 
    h = solr_search_params
    h[:sort].should == 'title_sort asc'
  end

  it "should do nothing if a query string is provided (aka sort by relevancy)" do
    self.should_receive(:params).any_number_of_times.and_return({:q => 'asd'}) 
    h = self.solr_search_params
    h[:sort].should be_blank
  end

  it "should sort by last indexed timestamp for a specific collection" do
    self.should_receive(:params).any_number_of_times.and_return({:f => { 'rel_isMemberOfCollection_s' => ['org.wgbh.mla:pledge']} }) 
    h = solr_search_params
    h[:sort].should == 'timestamp desc'
  end

  it "should allow a random sort" do
    self.should_receive(:params).any_number_of_times.and_return({:sort => 'random'}) 
    h = solr_search_params
    h[:sort].should match(/random_/)
  end

  it "should do nothing if a sort parameter is provided" do
    self.should_receive(:params).any_number_of_times.and_return({:sort => 'abc'}) 
    h = solr_search_params
    h[:sort].should == 'abc'
  end


end
