#require 'pbcore'

module Openvault::Pbcore
  class UnsupportedMarcFormatType < RuntimeError; end
  PBCORE_NS = 'http://www.pbcore.org/PBCore/PBCoreNamespace.html'
  class Document
    attr_reader :pbcore
    def initialize(data)
      reader = Nokogiri::XML(data)
      @pbcore = reader
    end

    def xmlns
      { 'pbcore' => PBCORE_NS }
    end

    def to_xml
      @pbcore
    end


    def titles 
      @pbcore.xpath('//pbcore:pbcoreTitle', xmlns).map do |e|
        [e.xpath('pbcore:titleType', xmlns).first.content, e.xpath('pbcore:title', xmlns).first.content]
      end
    end

    def descriptions
      @pbcore.xpath('//pbcore:pbcoreDescription', 'pbcore' => PBCORE_NS).map do |e|
        [e.xpath('pbcore:descriptionType', xmlns).first.content, e.xpath('pbcore:description', xmlns).first.content]
      end
    end

    def publishers
       @pbcore.xpath('//pbcore:pbcorePublisher', 'pbcore' => PBCORE_NS).map do |e|
	  role = e.xpath('pbcore:publisherRole', xmlns).first
	  role = role.content unless role.nil?
         [role || 'Publisher', e.xpath('pbcore:publisher', xmlns).first.content]
       end
    end

    def subjects(authority=nil)
      m = '//pbcore:pbcoreSubject'
      unless authority.nil?
        m << '[pbcore:subjectAuthorityUsed="%s"]' % authority
      end 

      @pbcore.xpath(m,  'pbcore' => PBCORE_NS).map do |e|
        {:subjectAuthorityUsed => e.xpath('pbcore:subjectAuthorityUsed', xmlns).first.content, :subject => e.xpath('pbcore:subject', xmlns).first.content}
      end.group_by{|e| e[:subjectAuthorityUsed] }
    end

    def contributors 
      m = '//pbcore:pbcoreContributor'

      @pbcore.xpath(m,  'pbcore' => PBCORE_NS).map do |e|
        {:contributorRole => e.xpath('pbcore:contributorRole', xmlns).first.content, :contributor => e.xpath('pbcore:contributor', xmlns).first.content}
      end.group_by{|e| e[:contributorRole] }
    end
    def creators 
      m = '//pbcore:pbcoreCreator'

      @pbcore.xpath(m,  'pbcore' => PBCORE_NS).map do |e|
        {:creatorRole => e.xpath('pbcore:creatorRole', xmlns).first.content, :creator => e.xpath('pbcore:creator', xmlns).first.content}
      end.group_by{|e| e[:creatorRole] }
    end

    def instantiation
      @pbcore.xpath('//pbcore:pbcoreInstantiation',  'pbcore' => PBCORE_NS).map do |i| 
	h = {:to_xml => i }; 
	i.children.map do |e| 
	  h[e.name] = [] if h[e.name].nil?
	  h[e.name] << e.content
	end
        h
      end
    end

  def coverage
    @pbcore.xpath('//pbcore:pbcoreCoverage', 'pbcore' => PBCORE_NS).map do |e|
      {:coverageType => e.xpath('pbcore:coverageType', xmlns).first.content, :coverage => e.xpath('pbcore:coverage', xmlns).first.content }
    end.group_by {|e| e[:coverageType] }
  end
  end


end
