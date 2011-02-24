require 'rubygems'
gem 'soap4r'
require 'rest_client'
require 'nokogiri'
require 'fastercsv'
require 'ap'
require 'lib/openvault/fedora.rb'
require 'nokogiri'
require 'chronic'
require 'active_support/all'
$KCODE = 'UTF8'

namespace :openvault do
  desc "Index"
  task :index => :environment do

pids = FedoraRepo.relsext '
 SELECT ?pid FROM <#ri> WHERE {
 ?pid <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> <info:fedora/org.wgbh.openvault>
}
'

errors = []


pids.shift

pids.flatten.map { |x| x.gsub('info:fedora/', '') }.each do |pid|
  begin
  print pid + "\n"

doc = []

doc << ['id', pid.parameterize]
doc << ['pid_s', pid]

client = FedoraRepo.fedora_client(pid)

objectProfile = Nokogiri::XML(client['/?format=xml'].get)

objectProfile.xpath('/objectProfile/*').each do |tag|
  case tag.name
  when 'objModels'
      tag.xpath('model').each do |model|
        doc << ["objModel_s", "#{model.text}"]
      end
  when /Date/
      doc << ["#{tag.name}_dt", "#{tag.text}"]
    else
      doc << ["#{tag.name}_s", "#{tag.text}"]
  end
end


datastreams = Nokogiri::XML(client['datastreams?format=xml'].get)

     dc = Nokogiri::XML(client["datastreams/DC/content"].get)
     xmlns = {'dc' =>"http://purl.org/dc/elements/1.1/", 'dcterms' =>"http://purl.org/dc/terms/", 'fedora-rels-ext' =>"info:fedora/fedora-system:def/relations-external#", 'oai_dc' =>"http://www.openarchives.org/OAI/2.0/oai_dc/", 'rdf' =>"http://www.w3.org/1999/02/22-rdf-syntax-ns#", 'xsi' =>"http://www.w3.org/2001/XMLSchema-instance"}



     dc.xpath('//dc:*', xmlns).each do |tag|
       case tag.name
       when 'date'
         # replace with chronic parsing??
         doc << ["dc_date_year_i", (tag.text.scan(/(19\d\d)/) || tag.text.scan(/(\d{4})/)).flatten.first]
         doc << ["#{tag.namespace.prefix}_#{tag.name}_s", "#{tag.text}"]
       else
         doc << ["#{tag.namespace.prefix}_#{tag.name}_s", "#{tag.text}"]
       end
     end

   #  unless objectProfile.xpath('/objectProfile/objLabel').first.text.empty?
   #    doc << ['title_s', objectProfile.xpath('/objectProfile/objLabel').first.text]
   #    doc << ['slug_s', objectProfile.xpath('/objectProfile/objLabel').first.text.parameterize.to_s]
   #  else
       doc << ['title_s', dc.xpath('//dc:title', xmlns).first.text || pid]
       doc << ['slug_s', dc.xpath('//dc:title', xmlns).first.text.parameterize.to_s || pid.parameterize ]
   #  end

collections = FedoraRepo.relsext('SELECT ?collection FROM <#ri> WHERE {
                     {
                       <info:fedora/' + pid + '> <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> ?collection
                   } UNION {
                   <info:fedora/' + pid + '> <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> ?parent.
                   ?parent <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> ?collection.
                   } UNION {
                   <info:fedora/' + pid + '> <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> ?parent.
                   ?parent <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> ?parent2.
                   ?parent2 <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> ?collection.
                   }
                   }')

                   collections.shift

                   collections.flatten.each do |c|
                     doc << ['rel_isMemberOfCollection_s', c.gsub('info:fedora/', '')]
                   end


datastreams.xpath('//datastream/@dsid').each do |ds|
  dsid = ds.to_s
  datastream_info = client["datastreams/#{dsid}?format=xml"].get
  doc << ["media_dsid_s", dsid]
  doc << ["media_dsid_s", dsid.split('.').first]

  case dsid
    when 'DC'
    when 'PBCore'
      pbcore = Nokogiri::XML(client["datastreams/#{dsid}/content"].get)
      xmlns = { 'pbcore' => 'http://www.pbcore.org/PBCore/PBCoreNamespace.html'}
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
    when 'Transcript.tei_xml'
      tei = Nokogiri::XML(client["datastreams/#{dsid}/content"].get)
      xmlns = { 'tei' => 'http://www.tei-c.org/ns/1.0' }

      doc << ["tei_language_s", tei.xpath('//tei:langUsage/tei:language/@ident', xmlns).first.to_s]

      tei.xpath('//tei:keywords[contains(@scheme,"merlot.org")]/tei:term/text()', xmlns).each do |tag|
        doc << ["merlot_s", tag.text]
      end

      tei.xpath('//tei:body//tei:name', xmlns).each do |tag|
        doc << ["tei_#{tag['type']}_s", tei.xpath("//tei:term[@xml:id='#{tag['ref'].gsub(/^#/, '')}']/text()", xmlns).first.to_s]
      end

      tei.xpath('//tei:spanGrp[@type="topic"]/span', xmlns).each do |tag|
        doc << ["tei_topic_s", tag.text]
      end
      tei.xpath('//tei:spanGrp[@type="title"]/span', xmlns).each do |tag|
        doc << ["tei_title_s", tag.text]
      end

      doc << ["tei_t", tei.xpath('//tei:body', xmlns).first.text]

    when 'Transcript.newsml.xml'
    when /Video/
    when /Audio/
    when /Image/
  end
end
#print client['datastreams/PBCore/content'].get
#print client['datastreams/Transcript.tei_xml/content'].get

h = {}

doc.reject { |x| x.last.nil? or x.last.empty? }.each do |t|
  h[t.first.strip.gsub('__', '_')] ||= []
  h[t.first.strip.gsub('__', '_')] << t.last.strip
end

h['media_dsid_s'].uniq!

format = []
format << 'video' if h['media_dsid_s'].any? { |x| x =~ /video/i }
format << 'audio' if h['media_dsid_s'].any? { |x| x =~ /audio/i }
format << 'image' if h['media_dsid_s'].any? { |x| x =~ /image/i }
format << 'tei' if h['media_dsid_s'].any? { |x| x =~ /tei/i }
format << 'newsml' if h['media_dsid_s'].any? { |x| x =~ /newsml/i }

format = ['collection'] if h['objModel_s'].any? { |x| x =~ /collection/i } or h['dc_type_s'].any? { |x| x =~ /collection/i }
format = ['program'] if h['objModel_s'].any? { |x| x =~ /program/i } or h['dc_type_s'].any? { |x| x =~ /program/i }
format = ['series'] if h['objModel_s'].any? { |x| x =~ /series/i } or h['dc_type_s'].any? { |x| x =~ /series/i }

h['format'] = format.join("_")


h['merlot_s'] = h['merlot_s'].map do |x|
  arr = []
 z = x.split('--')
 arr << z.shift
 z.each { |x| arr << [arr.last.to_s, x.strip].join(" -- ") }
 arr
end.flatten.uniq if h['merlot_s']

h.select { |k, v| v.length == 1 }.each { |k, v| 
 h[k] = v.first
}

h['title_display'] = h['title_s']
h['title_sort'] = h['title_s']

h['pbcore_pbcoreTitle_program_s'] = (h['pbcore_pbcoreTitle_series_s'] + " / " + h['pbcore_pbcoreTitle_program_s'] rescue h['pbcore_pbcoreTitle_program_s']) if h['pbcore_pbcoreTitle_series_s'] and  h['pbcore_pbcoreTitle_program_s'] 

prefix = h['pid_s'].split(':').last
prefix = prefix.slice(-6, 6) if prefix.length > 10

h['id'] = "#{prefix.parameterize}-#{h['slug_s']}" unless h['slug_s'].blank?

h['pid_short_s'] = prefix



Blacklight.solr.add h
  rescue
    print $!
     errors << pid
  end
end

Blacklight.solr.commit

print "Errors: "      
print "---------------------"
print errors.join "\n"
  end
end
