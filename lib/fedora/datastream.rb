module Fedora
  module Datastream
    def self.new *args
      Generic.new *args
    end

    class Generic
      attr_accessor :name
      attr_reader :opts
      attr_accessor :source
      attr_accessor :content_type
    
      def initialize name, opts={}, source=nil, content_type='text/plain'
        @opts = {:controlGroup => 'M', :dsLabel => name, :checksumType => 'DISABLED'}.merge opts
        @source = source
        @name = name
        @content_type = content_type
      end

      def to_s
        self.content
      end

      def content
        source || open(@opts['dsLocation']).read rescue nil
      end
    
      def add client
        client['/datastreams/' + name  + '?' + (opts.map { |k,v| k.to_s + "=" + CGI::escape(v) }.join('&'))].post source, :content_type => content_type
      end
    end
  end
end
