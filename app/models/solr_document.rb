class SolrDocument 
  include Blacklight::Solr::Document
  include BlacklightUserGeneratedContent::Document
  include BlacklightUserGeneratedContent::Commentable
  include BlacklightUserGeneratedContent::Taggable


  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Email )
  
  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Sms )

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension( Blacklight::Solr::Document::DublinCore)    
  field_semantics.merge!(    
                         :title => "title_display",
                         :author => "dc_creator_s",
                         :language => "language_facet",
                         :format => "format"
                        )

  SolrDocument.use_extension( Openvault::Solr::Document::Fedora)
  SolrDocument.use_extension( Blacklight::Solr::Document::DublinCore)
  SolrDocument.use_extension( Openvault::Solr::Document::Thumbnail)
  SolrDocument.use_extension( Openvault::Solr::Document::Pbcore)
  SolrDocument.use_extension( BlacklightOembed::Solr::Document::OembedRich )  
  #
  #

  after_save do
     Blacklight.solr.add fedora_object.to_solr, :add_attributes => { :commitWithin => 10 } rescue nil
  end

  def ==  a
    a.is_a?(SolrDocument) && self.id == a.id 
  end

  def inspect
    "#<SolrDocument:#{self.object_id} id=#{id} @_source=#{@_source.inspect} @export_formats=#{@export_formats.inspect}>"
  end

  def self.connection
    Blacklight.solr
  end

end
