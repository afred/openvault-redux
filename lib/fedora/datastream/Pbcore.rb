module Fedora::Datastream
   class Pbcore < Generic
     def initialize name, opts={}, source=nil, content_type='text/plain'
       @opts = {:controlGroup => 'M', :dsLabel => name, :checksumType => 'DISABLED'}.merge opts
       @source = source
       @name = name
       @content_type = content_type
     end

     def to_solr sum
      pbcore = Nokogiri::XML(content)
      xmlns = { 'pbcore' => 'http://www.pbcore.org/PBCore/PBCoreNamespace.html'}
      doc = []
      pbcore.xpath('/pbcore:PBCoreDescriptionDocument/pbcore:*', xmlns).each do |tag|
        case tag.name
        when 'pbcoreIdentifier'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:identifierSource/text()', xmlns).first.to_s.parameterize.to_s}_s",  tag.xpath('pbcore:identifier/text()', xmlns).first.to_s]
        when 'pbcoreTitle'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:titleType/text()', xmlns).first.to_s.parameterize.to_s}_s",  tag.xpath('pbcore:title/text()', xmlns).first.to_s]
        when 'pbcoreSubject'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:subjectAuthorityUsed/text()', xmlns).first.to_s.parameterize.to_s}_s",  tag.xpath('pbcore:subject/text()', xmlns).first.to_s]

        when 'pbcoreDescription'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:descriptionType/text()', xmlns).first.to_s.parameterize.to_s}_s",  tag.xpath('pbcore:description/text()', xmlns).first.to_s]
        when 'pbcoreContributor'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:contributorRole/text()', xmlns).first.to_s.parameterize.to_s}_s",  tag.xpath('pbcore:contributor/text()', xmlns).first.to_s]
        when 'pbcorePublisher'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:publisherRole/text()', xmlns).first.to_s.parameterize.to_s}_s",  tag.xpath('pbcore:publisher/text()', xmlns).first.to_s]
        when 'pbcoreCreator'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:creatorRole/text()', xmlns).first.to_s.parameterize.to_s}_s",  tag.xpath('pbcore:creator/text()', xmlns).first.to_s]
        when 'pbcoreCoverage'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:coverageType/text()', xmlns).first.to_s.parameterize.to_s}_s",  tag.xpath('pbcore:coverage/text()', xmlns).first.to_s]
      end




      end
        if pbcore.xpath('/pbcore:PBCoreDescriptionDocument/pbcore:pbcoreInstantiation', xmlns).first
          inst = pbcore.xpath('/pbcore:PBCoreDescriptionDocument/pbcore:pbcoreInstantiation', xmlns).first
          inst.xpath('pbcore:*', xmlns).each do |tag|
            case tag.name
              when 'pbcoreAnnotation'
              when 'pbcoreFormatID'
                doc << ["pbcore_pbcoreInstantiation_pbcoreFormatID_#{tag.xpath('pbcore:formatIdentifierSource/text()', xmlns).first.to_s.parameterize.to_s}_s", tag.xpath('pbcore:formatIdentifier/text()', xmlns).first.to_s]
              else
                doc << ["pbcore_pbcoreInstantiation_#{tag.name}_s", tag.text]
            end
          end
        end

        doc.inject({}) do |sum, (key,value)|
          next if value.blank?
          key.gsub!('__', '_')
          sum[key] ||= []
          sum[key] <<  value.strip

          sum
        end

     end 
   end
end
