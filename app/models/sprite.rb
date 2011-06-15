class Sprite
  require 'RMagick'
  attr_reader :name, :document_list
  attr_accessor :options

  def initialize name, document_list, options = { :style => :thumbnail, :width => 54, :height => 42 }
    @document_list = document_list
    @name = name
    @options = options
  end

  def image
    @image ||= Magick::Image.new(document_list.length*options[:width], options[:height]) 
  end

  def [] document
    { :x => document_list.index(document)*options[:width], :y => 0 }
  end

  def generate!(force = false)
    return if exists? and not force

    document_list.each_with_index do |document, i|
      img = Magick::ImageList.new(File.join(Rails.root, "public",document.thumbnail.url(:style => :thumbnail)))
      image.composite!(img, options[:width] * i, 0, Magick::OverCompositeOp)
    end

    image.write(image_path)
  end

  def image_path
     "#{Rails.root}/public/images/sprites/#{name}.jpg"
  end

  def exists?
    File.exists? image_path
  end

end
