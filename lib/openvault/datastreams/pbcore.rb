module Openvault::Datastreams
   module Pbcore
     def to_solr solr_doc = {}
      super(solr_doc)

      begin

      solr_doc['pbcore_s'] = content
      pbcore = Nokogiri::XML(content) 
      xmlns = { 'pbcore' => 'http://www.pbcore.org/PBCore/PBCoreNamespace.html'}
      doc = []
      pbcore.xpath('/pbcore:PBCoreDescriptionDocument/pbcore:*', xmlns).each do |tag|
        case tag.name
        when 'pbcoreIdentifier'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:identifierSource/text()', xmlns).first.text.parameterize.to_s}_s",  tag.xpath('pbcore:identifier/text()', xmlns).first.text]
        when 'pbcoreTitle'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:titleType/text()', xmlns).first.text.parameterize.to_s}_s",  tag.xpath('pbcore:title/text()', xmlns).first.text]
        when 'pbcoreSubject'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:subjectAuthorityUsed/text()', xmlns).first.text.parameterize.to_s}_s",  tag.xpath('pbcore:subject/text()', xmlns).first.text]

        when 'pbcoreDescription'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:descriptionType/text()', xmlns).first.text.parameterize.to_s}_s",  tag.xpath('pbcore:description/text()', xmlns).first.text]
        when 'pbcoreContributor'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:contributorRole/text()', xmlns).first.text.parameterize.to_s}_s",  tag.xpath('pbcore:contributor/text()', xmlns).first.text]
        when 'pbcorePublisher'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:publisherRole/text()', xmlns).first.text.parameterize.to_s}_s",  tag.xpath('pbcore:publisher/text()', xmlns).first.text]
        when 'pbcoreCreator'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:creatorRole/text()', xmlns).first.text.parameterize.to_s}_s",  tag.xpath('pbcore:creator/text()', xmlns).first.text]
        when 'pbcoreCoverage'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:coverageType/text()', xmlns).first.text.parameterize.to_s}_s",  tag.xpath('pbcore:coverage/text()', xmlns).first.text]
      end




      end
        if pbcore.xpath('/pbcore:PBCoreDescriptionDocument/pbcore:pbcoreInstantiation', xmlns).first
          inst = pbcore.xpath('/pbcore:PBCoreDescriptionDocument/pbcore:pbcoreInstantiation', xmlns).first
          inst.xpath('pbcore:*', xmlns).each do |tag|
            case tag.name
              when 'pbcoreAnnotation'
              when 'pbcoreFormatID'
                doc << ["pbcore_pbcoreInstantiation_pbcoreFormatID_#{tag.xpath('pbcore:formatIdentifierSource/text()', xmlns).first.text.parameterize.to_s}_s", tag.xpath('pbcore:formatIdentifier/text()', xmlns).first.text]
              else
                doc << ["pbcore_pbcoreInstantiation_#{tag.name}_s", tag.text]
            end
          end
        end

        doc.each do |key, value|
          key.gsub!('__', '_')
          solr_doc[key] ||= []
          solr_doc[key] <<  value.strip
        end

      rescue
      end
     end 
   end
end
