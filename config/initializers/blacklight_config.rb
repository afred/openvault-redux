# You can configure Blacklight from here. 
#   
#   Blacklight.configure(:environment) do |config| end
#   
# :shared (or leave it blank) is used by all environments. 
# You can override a shared key by using that key in a particular
# environment's configuration.
# 
# If you have no configuration beyond :shared for an environment, you
# do not need to call configure() for that envirnoment.
# 
# For specific environments:
# 
#   Blacklight.configure(:test) {}
#   Blacklight.configure(:development) {}
#   Blacklight.configure(:production) {}
# 

Blacklight.configure(:shared) do |config|

  # Set up and register the default SolrDocument Marc extension
  SolrDocument.extension_parameters[:marc_source_field] = :marc_display
  SolrDocument.extension_parameters[:marc_format_type] = :marc21
  SolrDocument.use_extension( Blacklight::Solr::Document::Marc) do |document|
    document.key?( :marc_display  )
  end

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  SolrDocument.use_extension( Blacklight::Solr::Document::DublinCore)
  SolrDocument.use_extension( Openvault::Solr::Document::Thumbnail)
    
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  SolrDocument.field_semantics.merge!(    
    :title => "title_display",
    :author => "dc_creator_s",
    :language => "tei_lang_s"  
  )
        
  
  ##############################

  config[:default_solr_params] = {
    :qt => "search",
    :per_page => 10 
  }
  
  
  

  # solr field values given special treatment in the show (single result) view
  config[:show] = {
    :html_title => "title_display",
    :heading => "title_display",
    :display_type => "format"
  }

  # solr fld values given special treatment in the index (search results) view
  config[:index] = {
    :show_link => "title_display",
    :record_display_type => "format"
  }

  # solr fields that will be treated as facets by the blacklight application
  #   The ordering of the field names is the order of the display
  # TODO: Reorganize facet data structures supplied in config to make simpler
  # for human reading/writing, kind of like search_fields. Eg,
  # config[:facet] << {:field_name => "format", :label => "Format", :limit => 10}
  config[:facet] = {
    :field_names => (facet_fields = [
      "format",
      "dc_type_s",
      "media_dsid_s",
      "dc_date_year_i",
      "person_cv",
      "place_cv",
      "event_cv",
      "objModel_s",
      "keywords_cv",
      "rel_isMemberOfCollection_s",
      "pbcore_pbcoreTitle_series_s",
      "pbcore_pbcoreTitle_program_s"
    ]),
    :labels => {
      "format" => "display partial",
      "dc_type_s" => "Format",
      "media_dsid_s" => "Media",
      "dc_date_year_i" => "Date",
      "person_cv" => "People",
      "place_cv" => "Place",
      "event_cv" => "Event",
      "objModel_s" => "Model",
      "keywords_cv" => "Keywords",
      "rel_isMemberOfCollection_s" => "Is Member Of Collection",
      "pbcore_pbcoreTitle_series_s" => "Series title",
      "pbcore_pbcoreTitle_program_s" => "Program title",
    },
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.    
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or 
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.     
    :limits => {
      "format" => 15, 
      "dc_date_year_i" => 15, 
      "person_cv" => 15, 
      "place_cv" => 15, 
      "event_cv" => 15, 
      "objModel_s" => 15, 
      "keywords_cv" => 15
    }
  }

  # Have BL send all facet field names to Solr, which has been the default
  # previously. Simply remove these lines if you'd rather use Solr request
  # handler defaults, or have no facets.
  config[:default_solr_params] ||= {}
  config[:default_solr_params][:"facet.field"] = facet_fields

  # solr fields to be displayed in the index (search results) view
  #   The ordering of the field names is the order of the display 
  config[:index_fields] = {
    :field_names => [
      "dc_description_t",
      "fulltext_t_highlight",
      "dc_date_s",
      "media_dsid_s",
      "pbcore_pbcoreInstantiation_formatGenerations_s",
      "pbcore_pbcoreTitle_program_s" 
    ],
    :labels => {
      "dc_description_t" => "Description",
      "fulltext_t_highlight" => "Text",
      "dc_date_s" => "Date Created",
      "media_dsid_s" => "Media",
      "pbcore_pbcoreInstantiation_formatGenerations_s" => "Generation",
      "pbcore_pbcoreTitle_program_s" => "Program",
    },
    :highlight => [
     "dc_description_t"
    ]
  }

  # solr fields to be displayed in the show (single result) view
  #   The ordering of the field names is the order of the display 
  config[:show_fields] = {
    :field_names => [
      "title_display",
    ],
    :labels => {
      "title_display"           => "Title:",
    }
  }


  # "fielded" search configuration. Used by pulldown among other places.
  # For supported keys in hash, see rdoc for Blacklight::SearchFields
  #
  # Search fields will inherit the :qt solr request handler from
  # config[:default_solr_parameters], OR can specify a different one
  # with a :qt key/value. Below examples inherit, except for subject
  # that specifies the same :qt as default for our own internal
  # testing purposes.
  #
  # The :key is what will be used to identify this BL search field internally,
  # as well as in URLs -- so changing it after deployment may break bookmarked
  # urls.  A display label will be automatically calculated from the :key,
  # or can be specified manually to be different. 
  config[:search_fields] ||= []

  # This one uses all the defaults set by the solr request handler. Which
  # solr request handler? The one set in config[:default_solr_parameters][:qt],
  # since we aren't specifying it otherwise. 
  config[:search_fields] << {
    :key => "all_fields",  
    :display_label => 'All Fields'   
  }

  # Now we see how to over-ride Solr request handler defaults, in this
  # case for a BL "search field", which is really a dismax aggregate
  # of Solr search fields. 
  config[:search_fields] << {
    :key => 'title',     
    # solr_parameters hash are sent to Solr as ordinary url query params. 
    :solr_parameters => {
      :"spellcheck.dictionary" => "title"
    },
    # :solr_local_parameters will be sent using Solr LocalParams
    # syntax, as eg {! qf=$title_qf }. This is neccesary to use
    # Solr parameter de-referencing like $title_qf.
    # See: http://wiki.apache.org/solr/LocalParams
    :solr_local_parameters => {
      :qf => "$title_qf",
      :pf => "$title_pf"
    }
  }
  
  # "sort results by" select (pulldown)
  # label in pulldown is followed by the name of the SOLR field to sort by and
  # whether the sort is ascending or descending (it must be asc or desc
  # except in the relevancy case).
  # label is key, solr field is value
  config[:sort_fields] ||= []
  config[:sort_fields] << ['relevance', 'score desc, pub_date_sort desc, title_sort asc']
  config[:sort_fields] << ['title', 'title_sort asc, pub_date_sort desc']
  config[:sort_fields] << ['year', 'dc_date_year_i desc, title_sort asc']
  
  # If there are more than this many search results, no spelling ("did you 
  # mean") suggestion is offered.
  config[:spell_max] = 5

  config[:mlt] = {
    :fields => ["title_t", "dc_description_t", "pbcore_pbcoreTitle_s"],
    :count => 3
  }

  config[:highlight] = {
   'hl.fl' => ['fulltext_t', 'dc_description_t'],
   'f.dc_description_t.hl.fragsize' => 50000
  }
end

