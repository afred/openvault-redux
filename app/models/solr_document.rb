class SolrDocument 

  extend ActiveModel::Naming
  extend ActiveModel::Callbacks
  define_model_callbacks :destroy, :save
  include ActiveRecord::Associations
  include ActiveRecord::Reflection

  def self.base_class
    self
  end

  def self.compute_type(type_name)
    ActiveSupport::Dependencies.constantize(type_name)
  end

  def quoted_id
    ActiveRecord::Base.quote_value get(:id)
  end

  def self.quote_value *args
    ActiveRecord::Base.quote_value *args
  end

  def interpolate_and_sanitize_sql *args
    Surrogate.new.send :interpolate_and_sanitize_sql, *args
  end

  def new_record?
    false
  end

  def self.table_exists?
     false
  end

  def destroyed?
    false
  end

  include Blacklight::Solr::Document

  include Juixe::Acts::Commentable
  extend ActsAsTaggableOn::Taggable

  acts_as_commentable
  acts_as_taggable_on :tags
  
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
 # SolrDocument.use_extension( BlacklightOembed::Solr::Document::OembedRich )  
  #
  #
  def self.find *args
    if args.first.is_a? String
      return SolrDocument.new :id => args.first
    end
    super(*args)
  end

  def save
    _run_save_callbacks do
      Blacklight.solr.add fedora_object.to_solr, :add_attributes => { :commitWithin => 10 } rescue nil
    end
  end      
end
