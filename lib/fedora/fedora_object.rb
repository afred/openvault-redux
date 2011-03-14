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
  
      @datasteams.xpath('//datastream/@dsid').map { |ds| ds.to_s }
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

    private
    def pid_to_module m
      m.gsub('info:fedora/', '').titleize.gsub(':', '::').gsub(' ', '').constantize rescue nil
    end
  end
end
