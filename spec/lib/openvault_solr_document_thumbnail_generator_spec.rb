require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')   

describe Openvault::Solr::Document::Thumbnail::Generator do
  before(:each) do
  end

  describe "url" do
    it "should return the solr document thumbnail by default" do
      @mock_document = SolrDocument.new(:pid_s => 'pid', 'thumbnail_url_s' => 'http://example.org/favicon.ico')
      @mock_generator = Openvault::Solr::Document::Thumbnail::Generator.new(@mock_document)
      @mock_generator.url.should == 'http://example.org/favicon.ico'
    end

    it "should return the fedora thumbnail datastream if no solr document thumbnail is present" do
      @mock_document = SolrDocument.new(:pid_s => 'pid')
      @mock_fedora_object = mock("Fedora::FedoraObject")
      @mock_fedora_object.should_receive(:datastream_url).with("Thumbnail").and_return('http://local.fedora.server/get/pid/Thumbnail') 
      @mock_document.should_receive(:fedora_object).and_return(@mock_fedora_object)
      @mock_generator = Openvault::Solr::Document::Thumbnail::Generator.new(@mock_document)
      @mock_generator.url.should == 'http://local.fedora.server/get/pid/Thumbnail'
    end

    it "should return a pre-generated image if available" do
      @mock_document = SolrDocument.new(:pid_s => 'pid')
      @mock_generator = Openvault::Solr::Document::Thumbnail::Generator.new(@mock_document)

      File.should_receive(:exists?).with(File.join(Rails.root, "public", "system",  "thumbnails", "pid", "a_fake_style.jpg")).and_return(true)

      @mock_generator.url(:style => :a_fake_style).should == "/system/thumbnails/pid/a_fake_style.jpg"
    end

    it "should generate an image using Paperclip::Thumbnail according to the style configuration" do
      @mock_document = SolrDocument.new(:pid_s => 'test_pid', 'thumbnail_url_s' => 'spec/fixtures/thumbnail.jpg')
      @mock_generator = Openvault::Solr::Document::Thumbnail::Generator.new(@mock_document)
      @mock_generator.url(:style => :preview).should == "/system/thumbnails/test_pid/preview.jpg" 
    end
  end
end
