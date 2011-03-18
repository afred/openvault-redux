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
      unless @profile
        profilexml = client['/?format=xml'].get
        profilexml.gsub! '<objectProfile', '<objectProfile xmlns="http://www.fedora.info/definitions/1/0/access/"' unless profilexml =~ /xmlns=/
        @profile ||= Nokogiri::XML(profilexml)
      end

      h = {}
      xmlns = { 'access' => "http://www.fedora.info/definitions/1/0/access/"}
      @profile.xpath('/access:objectProfile/*', xmlns).map { |tag| h[tag.name] ||= []; h[tag.name] << tag.text }
      h['objModels'] = []
      @profile.xpath('/access:objectProfile/access:objModels/access:model', xmlns).each { |tag| h['objModels'] << tag.text }
      h
    end

    def models
      self.profile['objModels']
    end

    
    def datastreams
      unless @datastreams
        datastreamsxml = client['datastreams?format=xml'].get
        datastreamsxml.gsub! '<objectDatastreams', '<objectDatastreams xmlns="http://www.fedora.info/definitions/1/0/access/"' unless datastreamsxml =~ /xmlns=/
        @datastreams ||= Nokogiri::XML(datastreamsxml)
      end
  
      @datastreams.xpath('//access:datastream/@dsid', {'access' => "http://www.fedora.info/definitions/1/0/access/"}).map { |ds| ds.to_s }
    end
  
    def datastream_url datastream, options = {}
      url = @repository.object_url(:pid => pid, :datastream => datastream, :private => options[:private])
    end
  
    def datastream dsid, options = {}
      @datastream ||= {}
      return @datastream[dsid] if @datastream[dsid]

      content = client["datastreams/#{dsid}/content"].get
      ds = "Fedora::Datastream::#{dsid.downcase.parameterize('_').camelize}".constantize.new(dsid, {}, content) rescue nil

      @datastream[dsid] = ds || content

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
      doc = ({
        "id" => self.pid.parameterize.to_s,
        "pid_s" => self.pid,
      }).merge(object_profile_to_solr).merge(datastreams_to_solr).merge(relations_to_solr).reject { |k,v| v.blank? }

      doc
    end

    protected
    def object_profile_to_solr
      h = Hash.new

      self.profile.each do |key, value|
         case key
           when /Date/
             h["#{key}_dt"] = value
             h["#{key}_s"] = value
           else
             h["#{key}_s"] = value
         end
      end

      h
    end

    def datastreams_to_solr
      sum = {"disseminates_s" => self.datastreams }

      self.datastreams.select { |x| "Fedora::Datastream::#{x.downcase.parameterize("_").camelize}".constantize rescue false }.map { |x| self.datastream(x) }.select { |x| x.respond_to? :to_solr }.each do |datastream|
        sum.merge!(datastream.to_solr(sum))
      end


      self.datastreams.select { |x| self.respond_to? "#{x.parameterize("_")}_to_solr".to_sym }.each do |datastream|
        sum.merge!(self.send("#{datastream.parameterize("_")}_to_solr".to_sym, sum, datastream))
      end

      sum
    end

    def relations_to_solr
      @repository.sparql("SELECT ?relation ?object FROM <#ri> WHERE {
                                          {
  <info:fedora/#{pid}> ?relation ?object
} UNION {
<info:fedora/#{pid}> ?relation ?parent.
?parent ?relation ?object
} UNION {
<info:fedora/#{pid}> ?relation ?parent.
?parent ?relation ?parent2.
?parent2 ?relation ?object
}
FILTER (?relation = <fedora-rels-ext:isMemberOfCollection>)
                          }").inject({}) do |h, row|
                            solr_field = "rel_#{row.first.split('#').last}_s"
                            h[solr_field] ||= []
                            h[solr_field] << row.last
                            h
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

      h["title_s"] = (doc.xpath('//dc:title/text()', xmlns).first || h["pid_s"]).to_s
      h["slug_s"] = h["title_s"].parameterize.to_s
      h
    end

    private
    def pid_to_module m
      m.gsub('info:fedora/', '').titleize.gsub(':', '/').camelize.constantize rescue nil
    end
  end
end
