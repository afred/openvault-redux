module Openvault::Solr::Document::UserGeneratedContent
  def self.included base
    # ActiveModel/ActiveRecord stuff
    base.send :extend, ActiveModel::Naming
    base.send :extend, ActiveModel::Callbacks
    base.send :define_model_callbacks, :destroy, :save
    base.send :include, ActiveRecord::Associations
    base.send :include, ActiveRecord::Reflection

    # Mock ActiveRecord methods only to the extent required
    base.send :extend, ActiveRecordClassMethods
    base.send :include, ActiveRecordInstanceMethods
    base.send :extend, RsolrFinder

    # Because `base` is likely /NOT/ an ActiveRecord, it doesn't automatically get these modules
    base.send :include, Juixe::Acts::Commentable
    base.send :extend, ActsAsTaggableOn::Taggable
    base.send :acts_as_commentable
    base.send :acts_as_taggable_on, :tags
  end

  # ActiveRecord mock methods
  module ActiveRecordClassMethods
    def base_class
      self
    end
    
    def compute_type(type_name)
      ActiveSupport::Dependencies.constantize(type_name)
    end
    
    def quote_value *args
      ActiveRecord::Base.quote_value *args
    end
    
    def table_exists?
       false
    end

  end

  # Override RSolr finder method to mock ActiveRecord#find
  module RsolrFinder
    # Provide  a mock method for #find
    # XXX this seems slightly dangerous as is, but seems to work well enough
    def find *args
      if args.first.is_a? String
        # TODO this could presumably go fetch the record from Solr
        return SolrDocument.new :id => args.first
      end
      super(*args)
    end
  end
  
  # ActiveRecord instance mock methods
  module ActiveRecordInstanceMethods
    def quoted_id
      ActiveRecord::Base.quote_value id
    end
  
    def interpolate_and_sanitize_sql *args
      # XXX interpolate_and_sanitize_sql is an ActiveRecord::Base method,
      # XXX rather than create a mock object or something, just use a model we know a priori exists
      ActsAsTaggableOn::Tag.new.send  :interpolate_and_sanitize_sql, *args
    end
  
    def new_record?
      false
    end
  
    def destroyed?
      false
    end

    def persisted?
      false
    end
  end

  # Calling SolrDocument#save must run the ActiveModel::Callbacks in order to persist Tags
  def save
    _run_save_callbacks do
    end
  end

end

