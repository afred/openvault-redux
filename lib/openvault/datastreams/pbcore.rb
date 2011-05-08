module Openvault::Datastreams
   module Pbcore
     def to_solr solr_doc = {}
      super(solr_doc)

      solr_doc['pbcore_s'] = content
      pbcore = Nokogiri::XML(content) 
      xmlns = { 'pbcore' => 'http://www.pbcore.org/PBCore/PBCoreNamespace.html'}
      doc = []
      pbcore.xpath('/pbcore:PBCoreDescriptionDocument/pbcore:*', xmlns).each do |tag|
        case tag.name
        when 'pbcoreIdentifier'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:identifierSource', xmlns).first.text.parameterize.to_s}_s",  tag.xpath('pbcore:identifier', xmlns).first.text]
        when 'pbcoreTitle'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:titleType', xmlns).first.text.parameterize.to_s}_s",  tag.xpath('pbcore:title', xmlns).first.text]
        when 'pbcoreSubject'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:subjectAuthorityUsed', xmlns).first.text.parameterize.to_s}_s",  tag.xpath('pbcore:subject', xmlns).first.text]

        when 'pbcoreDescription'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:descriptionType', xmlns).first.text.parameterize.to_s}_s",  tag.xpath('pbcore:description', xmlns).first.text]
        when 'pbcoreContributor'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:contributorRole', xmlns).first.text.parameterize.to_s}_s",  tag.xpath('pbcore:contributor', xmlns).first.text]
        when 'pbcorePublisher'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:publisherRole', xmlns).first.text.parameterize.to_s rescue nil}_s",  tag.xpath('pbcore:publisher', xmlns).first.text] if tag.xpath('pbcore:publisher', xmlns).first
        when 'pbcoreCreator'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:creatorRole', xmlns).first.text.parameterize.to_s rescue nil}_s",  tag.xpath('pbcore:creator', xmlns).first.text] if tag.xpath('pbcore:creator', xmlns).first
        when 'pbcoreCoverage'
          doc << ["pbcore_#{tag.name}_#{tag.xpath('pbcore:coverageType', xmlns).first.text.parameterize.to_s}_s",  tag.xpath('pbcore:coverage', xmlns).first.text]
      end




      end
        if pbcore.xpath('/pbcore:PBCoreDescriptionDocument/pbcore:pbcoreInstantiation', xmlns).first
          inst = pbcore.xpath('/pbcore:PBCoreDescriptionDocument/pbcore:pbcoreInstantiation', xmlns).first
          inst.xpath('pbcore:*', xmlns).each do |tag|
            case tag.name
              when 'pbcoreAnnotation'
              when 'pbcoreFormatID'
                doc << ["pbcore_pbcoreInstantiation_pbcoreFormatID_#{tag.xpath('pbcore:formatIdentifierSource', xmlns).first.text.parameterize.to_s}_s", tag.xpath('pbcore:formatIdentifier', xmlns).first.text]
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
     end 
   end
end
