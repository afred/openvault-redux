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
          :default => nil,
          :preview => "120x",
          :thumbnail => "54x42#",
          :feature => "380x",
          :poster => "320x240#"
        }
      }
    end

    def original
      require 'open-uri'
      thumbnail_url = @document.get('thumbnail_url_s') if @document.get('thumbnail_url_s')
      thumbnail_url ||= @document.fedora_object.repository.client.url + "/" + @document.fedora_object.datastream["Image.jpg"].url if @document.fedora_object.datastreams.keys.include? 'Image.jpg'
      thumbnail_url ||= @document.fedora_object.repository.client.url + "/" + @document.fedora_object.datastream["Thumbnail"].url if @document.fedora_object.datastreams.keys.include? 'Thumbnail'

      filename = File.join(base_path, @document.id.parameterize, "default.jpg")
      unless File.exists?(filename)
        FileUtils.mkdir_p dir_path
        File.open(filename, 'wb') { |f| f.write open(thumbnail_url).read } 
        FileUtils.chmod 0644, filename
      end

      if File.new(filename).size == 0
        FileUtils.rm filename 
        return nil
      end

      filename
    end

    def path(options= { :style => :default})
      begin
        filename = File.join(base_path, @document.id.parameterize, "#{options[:style]}.jpg")
        return filename if File.exists? filename

        style = config[:style][options[:style]]

        FileUtils.mkdir_p dir_path

        return File.join(Rails.root, 'public', 'images', '1x1.gif') unless original

        if style
          tn = Paperclip::Thumbnail.new File.open(original), { :geometry => style }

          dst = tn.make
          FileUtils.chmod 0644, dst.path
          FileUtils.mv dst.path, filename
          filename
        else
          original
        end
      rescue
        return File.join(Rails.root, 'public', 'images', '1x1.gif') unless original
      end
    end

    def url options = nil
      path(options).gsub(File.join(Rails.root, 'public'), '')
    end

    protected

    def base_url
      '/system/thumbnails'
    end

    def base_path
       File.join(Rails.root, "public", "system",  "thumbnails")
    end

    def dir_path
      File.join(base_path, @document.id.parameterize)
    end
  end
end
