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
end
