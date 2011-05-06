require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  include ApplicationHelper
  def params
    @params ||= {}
  end
 
  describe "application_name" do
    it "should be customized" do
      application_name.should == "WGBH Open Vault"
    end
  end      

end

