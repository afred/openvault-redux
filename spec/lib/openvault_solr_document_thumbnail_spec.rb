require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')   

describe Openvault::Solr::Document::Thumbnail do
  before(:each) do
    @mock_class = Class.new do
      include Blacklight::Solr::Document
    end

    @mock_class.use_extension(Openvault::Solr::Document::Thumbnail)
  end

  it "should register a jpg export format" do
    @mock_document = @mock_class.new
    Set.new(@mock_document.export_formats.keys).should be_superset(Set.new([:jpg]))
  end

  it "should register export_as_jpg_with_redirect to return the thumbnail url" do
    @mock_document = @mock_class.new
    @mock_thumbnail_generator = mock("Openvault::Solr::Document::Thumbnail::Generator")
    @mock_thumbnail_generator.should_receive('url').and_return('http://example.org/favicon.ico')
    @mock_document.should_receive(:thumbnail).and_return(@mock_thumbnail_generator)
    @mock_document.export_as_jpg_with_redirect.should == 'http://example.org/favicon.ico'
  end

  it "should return the thumbnail binary data" do
    @mock_document = @mock_class.new
    @mock_thumbnail_generator = mock("Openvault::Solr::Document::Thumbnail::Generator")
    @mock_thumbnail_generator.should_receive('url').and_return('http://example.org/favicon.ico')
    @mock_document.should_receive(:thumbnail).and_return(@mock_thumbnail_generator)
    @mock_file_handle = mock("FileHandle")
    @mock_file_handle.should_receive(:read).and_return('00001110')
    @mock_document.should_receive(:open).with('http://example.org/favicon.ico').and_return(@mock_file_handle)
    @mock_document.export_as_jpg.should == '00001110'
  end

  it "should provide access to the thumbnail generator" do
    @mock_document = @mock_class.new
    @mock_document.thumbnail.should be_a_kind_of(Openvault::Solr::Document::Thumbnail::Generator)
  end
end
