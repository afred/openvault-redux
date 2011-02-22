module Openvault::Solr::Document::Thumbnail
  class Generator
    def initialize document
      @document = document

      @basename = "#{@document.get('pid_s')}_Thumbnail".parameterize
      @format = "jpg"
    end

    def config
      { :style => {
          :preview => "160x90"
        }
      }
    end

    def url(options= { :style => :default})
      require 'open-uri'
      begin
      if options[:style] == :default
        return @document.get('thumbnail_url_s') || "http://localhost:8180/fedora/get/#{@document.get('pid_s')}/Thumbnail"
      end

      return "/system/thumbnails/#{@document.get('pid_s').parameterize}/#{options[:style]}.jpg" if File.exists? File.join(Rails.root, "public", "system",  "thumbnails", @document.get('pid_s').parameterize, "#{options[:style]}.jpg")

      style = config[:style][options[:style]]

      file = Tempfile.new([@basename, @format ? ".#{@format}" : ''])

      file.write open(url()).read
      file.rewind

      tn = Paperclip::Thumbnail.new file, { :geometry => style }

      dst = tn.make


      FileUtils.mkdir_p File.join(Rails.root, "public", "system",  "thumbnails", @document.get('pid_s').parameterize)
      FileUtils.cp dst.path, File.join(Rails.root, "public", "system",  "thumbnails", @document.get('pid_s').parameterize, "#{options[:style]}.jpg") 

      file.unlink
      dst.unlink

      "/system/thumbnails/#{@document.get('pid_s').parameterize}/#{options[:style]}.jpg"
      rescue
        ''
      end
    end

  end
end
