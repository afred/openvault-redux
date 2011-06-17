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
          :preview => "120x",
          :thumbnail => "54x42#",
          :feature => "380x",
          :poster => "320x240#"
        }
      }
    end

    def url(options= { :style => :default})
      require 'open-uri'
      begin
      if options[:style] == :default
        return @document.get('thumbnail_url_s') if @document.get('thumbnail_url_s')

        if @document.fedora_object.datastreams.keys.include? 'Image.jpg'
          return @document.fedora_object.repository.client.url + "/" + @document.fedora_object.datastream["Image.jpg"].url
        end

        return @document.fedora_object.repository.client.url + "/" + @document.fedora_object.datastream["Thumbnail"].url
      end

      return "#{base_url}/#{@document.get('pid_s').parameterize}/#{options[:style]}.jpg" if File.exists? File.join(dir_path, "#{options[:style]}.jpg")

      style = config[:style][options[:style]]
      raise "#{options[:style]} is not in #{config[:style][:keys].join ","}" unless style

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
      rescue => e
 	Rails.logger.warn("#{e.backtrace}")
	return "/images/1x1.gif"
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
