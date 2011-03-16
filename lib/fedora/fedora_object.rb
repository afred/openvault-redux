module Fedora
  module FedoraObject
    def self.find pid, repository = nil
      repository ||= Fedora.repository
      obj = Base.new(pid, repository)
    end

    def self.create pid, options = {}, repository=nil
      repository ||= Fedora.repository
      repository.client(pid).delete rescue nil
      repository.client(pid + "?#{options.map { |key, value| "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}"}.join("&")}").post nil

      return FedoraObject.find(pid, repository)
    end
    
    def pid
      @pid
    end

    def client
      @repository.client(pid)
    end
  
    def profile
      @profile ||= Nokogiri::XML(client['/?format=xml'].get)
      h = {}
      h['models'] ||= []
      @profile.xpath('/objectProfile/*').map { |tag| h[tag.name] ||= []; h[tag.name] << tag.text }
      @profile.xpath('/objectProfile/objModels/model').each { |tag| h['models'] << tag.text }
      h
    end

    def models
      self.profile['models']
    end

    
    def datastreams
      @datastreams ||= Nokogiri::XML(client['datastreams?format=xml'].get)
  
      @datastreams.xpath('//access:datastream/@dsid', {'access' => "http://www.fedora.info/definitions/1/0/access/"}).map { |ds| ds.to_s }
    end
  
    def datastream_url datastream, options = {}
      url = @repository.object_url(:pid => pid, :datastream => datastream, :private => options[:private])
    end
  
    def datastream datastream, options = {}
      instance_variable_get "@#{datastream}" if instance_variable_defined? "@#{datastream}"
      instance_variable_set "@#{datastream}", client["datastreams/#{datastream}/content"].get
    end
  end

  class Base
    include FedoraObject
    def initialize pid, repository = nil
      @repository = repository
      @pid = pid

      self.models.each do |m|
        m = pid_to_module(m)

        if m
          self.extend(m)
        end
      end

    end

    def to_solr
      ({
        :id => self.pid.parameterize.to_s,
        :pid_s => self.pid,
      }).merge(object_profile_to_solr).merge(datastreams_to_solr).reject { |k,v| v.blank? }
    end

    protected
    def object_profile_to_solr
      h = Hash.new

      self.profile.each do |key, value|
         case key
           when "models"
             h["objModel_s"] = value
           when /Date/
             h["#{key}_dt"] = value
             h["#{key}_s"] = value
           else
             h["#{key}_s"] = value
         end
      end

    end

    def datastreams_to_solr
      self.datastreams.select { |x| self.respond_to? "#{x.parameterize("_")}_to_solr".to_sym }.inject({}) do |sum, datastream|
        sum.merge(self.send("#{datastream.parameterize("_")}_to_solr".to_sym, sum, datastream))
      end
    end

    def dc_to_solr sum,dsid
      h = {}
      doc = Nokogiri::XML(self.datastream(dsid))
      xmlns = {'dc' =>"http://purl.org/dc/elements/1.1/", 'dcterms' =>"http://purl.org/dc/terms/", 'fedora-rels-ext' =>"info:fedora/fedora-system:def/relations-external#", 'oai_dc' =>"http://www.openarchives.org/OAI/2.0/oai_dc/", 'rdf' =>"http://www.w3.org/1999/02/22-rdf-syntax-ns#", 'xsi' =>"http://www.w3.org/2001/XMLSchema-instance"}

      doc.xpath('//dc:*', xmlns).each do |tag|
        case tag.name
          when 'description'
            h["#{tag.namespace.prefix}_#{tag.name}_t"] = tag.text
          when 'date'
            h["dc_date_year_i"] = tag.text.scan(/(\d{4})/).flatten.first
            h["#{tag.namespace.prefix}_#{tag.name}_s"] = tag.text
          else
            h["#{tag.namespace.prefix}_#{tag.name}_s"] = tag.text
        end
      end

      h["title_s"] = doc.xpath('//dc:title', xmlns).first.text || h["pid_s"]
      h["slug_s"] = h["title_s"].parameterize.to_s
      h
    end

    private
    def pid_to_module m
      m.gsub('info:fedora/', '').titleize.gsub(':', '::').gsub(' ', '').constantize rescue nil
    end
  end
end
