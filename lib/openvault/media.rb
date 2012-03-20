module Openvault::Media
  def self.filename_to_url filename
    filename = File.basename(filename)
    case filename
      when /\.mp4$/
        "http://openvault.wgbh.org/media/videos/#{filename}"
      when /\.mp3$/
        "http://openvault.wgbh.org/media/audio/#{filename}"
      when /\.flv$/
        "http://openvault.wgbh.org/media/audio/#{filename}"
      when /\.jpe?g$/
        "http://openvault.wgbh.org/media/thumbnails/#{filename}"
      when /\.xml$/
        "http://openvault.wgbh.org/media/transcripts/#{filename}"
      else
        raise "Unknown file extension for file #{filename} in Openvault::Media.filename_to_url"
    end

  end
end
