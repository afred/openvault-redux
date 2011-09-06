module Openvault::Solr::Document::Pbcore
  def self.extended(document)
    document.will_export_as(:pbcore, "text/xml+pbcore")
    document.will_export_as(:openurl_ctx_kev, "application/x-openurl-ctx-kev")
  end
  def to_pbcore
    self.fedora_object.datastream["PBCore"].content.gsub('<?xml version="1.0" encoding="UTF-8"?>', '')
  end
  def export_as_pbcore
    self.to_pbcore
  end

  def export_as_openurl_ctx_kev(format = nil)

    creator = [self.get('pbcore_pbcoreContributor_producer_s'), self.get('pbcore_pbcoreContributor_presenter_s')].compact.first
    contributor = [self.get('pbcore_pbcoreContributor_interviewee_s'), self.get('pbcore_pbcoreContributor_guest_s')].compact.first
    place = [self.get('pbcore_pbcoreCoverage_spatial_s')].compact.first

    export_text = []
    
    export_text << "ctx_ver=Z39.88-2004"
    export_text << "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc"
    export_text << "rfr_id=info%3Asid%2Fblacklight.rubyforge.org%3Agenerator"

    export_text << "rft.genre=unknown"
    export_text << "rft.title=#{CGI::escape(self.get('title_display'))}" if self.get('title_display')
    export_text << "rft.creator=#{CGI::escape(creator)}" if creator
    export_text << "rft.contributor=#{CGI::escape(contributor)}" if contributor
    export_text << "rft.publisher=#{CGI::escape(self.get('pbcore_pbcorePublisher_t'))}" if self.get('pbcore_pbcorePublisher_t') 
    export_text << "rft.date=#{CGI::escape(self.get('dc_date_s'))}" if self.get('dc_date_s')
    export_text << "rft.place=#{CGI::escape(place)}" if place
    export_text << "rft.format=" + (CGI::escape(format)) if format

    export_text.join("&amp;").html_safe
  end

  def export_as_chicago_citation_txt
    text = ''

    title = setup_title_info
    if !title.nil?
      text += "&ldquo;" + mla_citation_title(title) + "&rdquo; "
    end
    text += ", "

    text += setup_pub_date unless setup_pub_date.nil?
    if text[-1,1] != "."
      text += ", " unless text.nil? or text.blank?
    end

    text += setup_series_info + ", " unless setup_series_info.nil?

    text += "WGBH Media Library &amp; Archives, "

    text += "(accessed " + Date.current.strftime("%d %b %Y") + ")"


    text.html_safe
     
  end

  def export_as_mla_citation_txt
    text = ''
    # setup title
    title = setup_title_info
    if !title.nil?
      text += "&ldquo;" + mla_citation_title(title) + "&rdquo; "
 end
    # Edition
    edition_data = setup_edition
    text += edition_data + " " unless edition_data.nil?

    # Get Pub Date
    text += setup_pub_date unless setup_pub_date.nil?
    if text[-1,1] != "."
      text += ". " unless text.nil? or text.blank?
    end

    # Publication
    text += setup_series_info + ", " unless setup_series_info.nil?

    text += "WGBH Media Library &amp; Archives, "

    text += "Web. "

    text += Date.current.strftime("%d %b %Y") + "."

    text.html_safe
    
  end

  def export_as_apa_citation_txt
    text = ''

    # setup title info
    title = setup_title_info
    text += title +" " unless title.nil?

    # Get Pub Date
    text += "(" + setup_pub_date + "). " unless setup_pub_date.nil?


    # Edition
    edition_data = setup_edition
    text += edition_data + " " unless edition_data.nil?

    # Publisher info
    text += "Boston, MA: WGBH Media Library &amp; Archives. "

    text += "Retrieved " + Date.current.strftime("%d %b %Y") + ""

    text.html_safe
  end

  def setup_pub_date
    date_value = self.get('dc_date_s') rescue ''
    date_value
  end
  def setup_pub_info
    text = self.get('dc_publisher_s')
    text ||= 'WGBH Media Library &amp; Archives'
    clean_end_punctuation(text.strip)
  end

  def setup_series_info
    self.get('pbcore_pbcoreTitle_title_Full_s')
  end

  def mla_citation_title(text)
    no_upcase = ["a","an","and","but","by","for","it","of","the","to","with"]
    new_text = []
    word_parts = text.split(" ")
    word_parts.each do |w|
      if !no_upcase.include? w
        new_text.push(w.capitalize)
      else
        new_text.push(w)
      end
    end
    new_text.join(" ")
  end

  def setup_title_info
    text = self.get('title_display')

    return nil if text.try(:strip).blank?
    clean_end_punctuation(text.strip) + "."

  end

  def clean_end_punctuation(text)
    if [".",",",":",";","/"].include? text[-1,1]
      return text[0,text.length-1]
    end
    text
 end
  def setup_edition
      return nil
  end

  def get_author_list
    author_list = []
    author_list = [self.get('dc.publisher')] unless self.get('dc.publisher').nil?

    author_list.uniq!
    author_list = ['WGBH Educational Foundation'] if author_list.length == 0
    author_list
  end

  def abbreviate_name(name)
    name
  end

  def name_reverse(name)
    name
  end
  
end
