require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')   

describe Openvault::SolrHelper::BoostMedia do
  include Blacklight::SolrHelper
  include Openvault::SolrHelper::BoostMedia

  it "should add a boost query to the solr search params" do
    self.should_receive(:params).any_number_of_times.and_return({}) 
    h = solr_search_params
    h.should be_a_kind_of(Hash)
    h[:bq].should_not be_blank
    h[:bq].should == ["media_dsid_s:Video^10000", "media_dsid_s:Audio^10000", "media_dsid_s:Transcript^50000"]
  end

  it "should not replace an existing bq" do
    self.should_receive(:extra_controller_params_whitelist).any_number_of_times.and_return([:bq])
    self.should_receive(:params).any_number_of_times.and_return({}) 
    h = solr_search_params(:bq => ['a:z^1000'])
    
    h[:bq].should_not be_blank
    h[:bq].should == ['a:z^1000']

  end
end
