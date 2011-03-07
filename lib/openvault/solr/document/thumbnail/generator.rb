module Openvault::Solr::Document::Thumbnail
  class Generator
    def initialize document
      @document = document

      @basename = "#{@document.get('pid_s')}_Thumbnail".parameterize
      @format = "jpg"
    end

    def to_json(*a)
      { :url => url(:style => :preview) }.to_json(*a)
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
        return @document.get('thumbnail_url_s') || @document.fedora_object.datastream_url("Thumbnail")
      end

      return "/system/thumbnails/#{@document.get('pid_s').parameterize}/#{options[:style]}.jpg" if File.exists? File.join(Rails.root, "public", "system",  "thumbnails", @document.get('pid_s').parameterize, "#{options[:style]}.jpg")

      style = config[:style][options[:style]]

      file = Tempfile.new([@basename, @format ? ".#{@format}" : ''])


      file.write open(url()).read
      file.rewind

      tn = Paperclip::Thumbnail.new file, { :geometry => style }

      dst = tn.make


      FileUtils.mkdir_p File.join(Rails.root, "public", "system",  "thumbnails", @document.get('pid_s').parameterize)
      FileUtils.mv dst.path, File.join(Rails.root, "public", "system",  "thumbnails", @document.get('pid_s').parameterize, "#{options[:style]}.jpg") 

      file.unlink
      dst.unlink

      "/system/thumbnails/#{@document.get('pid_s').parameterize}/#{options[:style]}.jpg"
      rescue
        return "/system/thumbnails/no-image-available-#{options[:style]}.jpg" if File.exists? File.join(Rails.root, "public", "system",  "thumbnails", "no-image-available-#{options[:style]}.jpg")
        file = File.join Rails.root, "public", "images", 'no-image-available.jpg'
        tn = Paperclip::Thumbnail.new open(file), { :geometry => style }
        dst = tn.make
        FileUtils.mv dst.path, File.join(Rails.root, "public", "system",  "thumbnails", "no-image-available-#{options[:style]}.jpg")
        "/system/thumbnails/no-image-available-#{options[:style]}.jpg"
      end
    end

  end
end
