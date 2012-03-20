module Openvault::DigitalObjects::Artesia
  module Asset

     def self.extended(document)
     end

     def add_metadata_sdef_datastreams!
         Rails.logger.info "  Adding DublinCore sdef datastream"
         ds = self['DublinCore']
         ds.dsLocation = "http://local.fedora.server/fedora/get/#{self.pid}/sdef:METADATA/DublinCore"
         ds.mimeType = 'text/xml'
         ds.controlGroup = 'E'
         ds.save
     
         Rails.logger.info "  Adding PBCore sdef datastream"
         ds = self['PBCore']
         ds.dsLocation = "http://local.fedora.server/fedora/get/#{self.pid}/sdef:METADATA/PBCore"
         ds.mimeType = 'text/xml'
         ds.controlGroup = 'E'
         ds.save

         self.save
     end

     def add_media_datastreams! files
         exifinfo = %x[ exiftool -X #{ files.join " " } ]

         ds = self['Exiftool']
         ds.content = exifinfo
         ds.mimeType = 'text/xml'
         ds.save

         doc = Nokogiri::XML(exifinfo)

         files.each do |f|
           xmlns = { 'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#', 'File' => 'http://ns.exiftool.ca/File/1.0/'}
           mime = doc.xpath("//rdf:Description[@rdf:about='#{f}']/File:MIMEType", xmlns).first.text rescue 'application/octet-stream'

           mime = 'video/mp4' if mime =~ /quicktime/ and f =~ /mp4/

           dsid = mime.gsub('x-', '').split("/").map(&:parameterize).join(".")
           dsid.gsub!('video/', 'audio/') if f =~ /^audio/
           dsid.gsub!('jpeg', 'jpg')
           dsid.gsub!('mpeg', 'mp3')
           dsid.gsub!('application', 'text') if dsid =~ /xml/
           dsid.capitalize!

           if dsid =~ /xml/
             root_name = Nokogiri::XML(open(f)).root.name
             root_name = 'newsml' if root_name =~ /news/
             dsid = dsid.split(".").insert(1, root_name.downcase).join(".")
           end
           dsid.gsub!('Text', 'Transcript') if dsid =~ /xml$/ and (dsid =~ /tei/ or dsid =~ /newsml/)
           Rails.logger.info "  Adding #{f} as #{self.pid}/#{dsid} from #{Openvault::Media.filename_to_url(f)}"
             
           ds = self[dsid]
           #ds.file = open(f)
           ds.dsLocation = Openvault::Media.filename_to_url(f)
           ds.mimeType = mime
           ds.controlGroup = 'R'
           ds.save

     end
     end

  end
end
