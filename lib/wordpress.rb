module Wordpress

  def self.endpoint
    @endpoint
  end

  def self.endpoint= endpoint
    @endpoint = endpoint
  end

  class Post
    def self.find id
      parsed_json = ActiveSupport::JSON.decode(open("#{endpoint}/#{id}?json=1").read)
      raise "Missing Wordpress Post" unless parsed_json["status"] == "ok"
      Post.new(parsed_json)
    end

    attr_accessor :page

    def initialize json
      page = parsed_json["page"]
    end

    def title
      page["title"]
    end

    def custom_fields
      page["custom_fields"]
    end

    def thumbnail
      page["thumbnail"]
    end

    def content
      page["content"]
    end
  end

  class Page < Post; end
end
