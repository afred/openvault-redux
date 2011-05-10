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
        return @document.get('thumbnail_url_s') || (@document.fedora_object.repository.client.url + "/" + @document.fedora_object.datastream["Thumbnail"].url)
      end

      return "#{base_url}/#{@document.get('pid_s').parameterize}/#{options[:style]}.jpg" if File.exists? File.join(dir_path, "#{options[:style]}.jpg")

      style = config[:style][options[:style]]

      file = Tempfile.new([@basename, @format ? ".#{@format}" : ''])


      file.write open(url()).read
      file.rewind

      tn = Paperclip::Thumbnail.new file, { :geometry => style }

      dst = tn.make
      FileUtils.chmod 0644, dst.path


      FileUtils.mkdir_p dir_path
      FileUtils.mv dst.path, File.join(dir_path, "#{options[:style]}.jpg") 

      file.unlink
      dst.unlink

      "#{base_url}/#{@document.get('pid_s').parameterize}/#{options[:style]}.jpg"
      rescue
        return "#{base_url}/no-image-available-#{options[:style]}.jpg" if File.exists? File.join(Rails.root, "public", "system",  "thumbnails", "no-image-available-#{options[:style]}.jpg")
        file = File.join Rails.root, "public", "images", 'no-image-available.jpg'
        tn = Paperclip::Thumbnail.new open(file), { :geometry => style }
        dst = tn.make
        FileUtils.mv dst.path, File.join(base_path, "no-image-available-#{options[:style]}.jpg")
        "#{base_url}/no-image-available-#{options[:style]}.jpg"
      end
    end

    protected
    def base_url
      "/system/thumbnails"
    end
    def base_path
       File.join(Rails.root, "public", "system",  "thumbnails")
    end

    def dir_path
      File.join(base_path, @document.get('pid_s').parameterize)
    end
  end
end
