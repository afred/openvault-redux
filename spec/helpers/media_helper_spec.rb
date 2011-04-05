require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MediaHelper do
  include MediaHelper

  describe "render_xml_with_xslt" do

  end

  describe "render_tei_transcript" do
    it "should run the appropriate xslt" do
      self.should_receive(:render_xml_with_xslt).with('source.xml', 'public/xslt/tei2timedtranscript.xsl').and_return("tei")
      render_tei_transcript('source.xml').should == "tei"
    end
  end

  describe "render_newsml_transcript" do
    it "should run the appropriate xslt" do
      self.should_receive(:render_xml_with_xslt).with('source.xml', 'public/xslt/newsml2html.xsl').and_return("newsml")
      render_newsml_transcript('source.xml').should == "newsml"
    end
  end

  describe "render_audio_player" do
    it "should return html" do
      arr = []
      self.should_receive(:extra_head_content).and_return(arr)
      html = render_audio_player("test.mp3")
      html.should_not be_empty
      html.should have_tag('audio')
    end
  end

  describe "render_video_player" do
    it "should return html" do
      arr = []
      self.should_receive(:extra_head_content).and_return(arr)
      self.should_receive(:stylesheet_links).and_return(arr)
      self.should_receive(:javascript_includes).and_return(arr)
      html = render_video_player("test.mp4")
      html.should_not be_empty
      html.should have_tag('video')
    end

    it "should accept fall-back sources" do
      arr = []
      self.should_receive(:extra_head_content).and_return(arr)
      self.should_receive(:stylesheet_links).and_return(arr)
      self.should_receive(:javascript_includes).and_return(arr)
      html = render_video_player(["test.mp4", "test.ogg"])
      html.should_not be_empty
      html.should have_tag('video')
      html.should have_tag('source[src="test.mp4"]')
      html.should have_tag('source[src="test.ogg"]')
    end
  end
end
