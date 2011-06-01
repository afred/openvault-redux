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

    
        
  
  ##############################

  config[:default_solr_params] = {
    :qt => "search",
    :per_page => 10,
    "f.merlot_s.facet.sort" => "index"
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
                     "merlot_s",
      "keywords_cv",
      "person_cv",
      "place_cv",
      "dc_date_year_i",
      "event_cv",
      "media_s",
      "dc_type_s",
      "pbcore_pbcoreTitle_series_s",
      "tags_s",
      "has_comments_query",
      "ri_collection_ancestors_s",
      "format",
      "timestamp_query",
      "objModels_s"
    ]),
    :labels => {
      "merlot_s" => "Category",
      "dc_type_s" => "Format",
      "media_s" => "Media",
      "dc_date_year_i" => "Date",
      "person_cv" => "People",
      "place_cv" => "Place",
      "event_cv" => "Event",
      "keywords_cv" => "Topic",
      "pbcore_pbcoreTitle_series_s" => "Series title",
      "tags_s" => "Tags",
      "has_comments_query" => "Comments",
      "objModels_s" => "Model",
      "ri_collection_ancestors_s" => "Collection",
      "format" => "display partial",
      "timestamp_query" => "date indexed",
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
      "format" => 10, 
      "person_cv" => 10, 
      "place_cv" => 10, 
      "event_cv" => 10, 
      "objModel_s" => 10, 
      "keywords_cv" => 10,
      "tags_s" => 10,
      "dc_type_s" => 10,
      "pbcore_pbcoreTitle_series_s" => 10
    },
    :range => {
      "dc_date_year_i" => true
    },
    :tag => {
      "format" => {
        :ex => "format"
      }
    },
    :query => {
      "timestamp_query" => {
         'today' => 'timestamp:[NOW/DAY TO *]',
         'this week' => "timestamp:[NOW-#{Time.now.wday}DAY/DAY TO *]",
         'this month' => 'timestamp:[NOW/MONTH TO *]',
         'this year' => 'timestamp:[NOW/YEAR TO *]'
      },
      "has_comments_query" => {
         'has comments' => 'comments_public_b:true',
         'has no comments' => 'comments_public_b:false'
         }
    },
    #:pivot => {
    #  "pbcore_pbcoreTitle_series_s" => ["pbcore_pbcoreTitle_series_s", "pbcore_pbcoreTitle_program_s"]
   # },
    :hierarchy => {
      "merlot_s" => true
    },

    :filter => {
      "ri_collection_ancestors_s" => Proc.new { |value| Blacklight.config[:collection_titles][value] || false }
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
      "fulltext_t",
      "dc_description_t",
      "dc_date_s",
      "media_s",
      "pbcore_pbcoreTitle_program_s" 
    ],
    :labels => {
      "fulltext_t" => "Text",
      "dc_description_t" => "Summary",
      "dc_date_s" => "Date Created",
      "media_s" => "Media",
      "pbcore_pbcoreTitle_program_s" => "Program"
    },
    :highlight => {
     "dc_description_t" => true,
     "fulltext_t" => { :default => '' }
    }
  }

  # solr fields to be displayed in the show (single result) view
  #   The ordering of the field names is the order of the display 
  config[:show_fields] = {
    :field_names => [
      "dc_description_t",
      "topic_cv"
    ],
    :labels => {
      "dc_description_t"           => "Summary:",
      "topic_cv" => "Topics:"
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
  config[:sort_fields] << ['relevance', 'score desc, title_sort asc']
  config[:sort_fields] << ['title', 'title_sort asc']
  config[:sort_fields] << ['year', 'dc_date_year_i desc, title_sort asc']
  
  # If there are more than this many search results, no spelling ("did you 
  # mean") suggestion is offered.
  config[:spell_max] = 5

  # Add documents to the list of object formats that are supported for all objects.
  # This parameter is a hash, identical to the Blacklight::Solr::Document#export_formats 
  # output; keys are format short-names that can be exported. Hash includes:
  #    :content-type => mime-content-type
  config[:unapi] = {
    'oai_dc_xml' => { :content_type => 'text/xml' } 
  }

  config[:mlt] = {
    :fields => "title_t, dc_description_ts, pbcore_pbcoreTitle_ts, ri_collection_ancestors_s",
    :qf => "title_ts^1000 ri_collection_ancestors_s^50",
    :count => 3
  }

  config[:highlight] = {
   'hl.fl' => ['fulltext_t', 'dc_description_t'],
   'f.fulltext_t.hl.snippets' => 3,
   'f.fulltext_t.hl.fragsize' => 300,
   'f.dc_description_t.hl.alternateField' => 'dc_description_t',
   'f.dc_description_t.hl.fragsize' => 50000
  }

  config[:oai] = {
   :provider => {
     :repository_name => 'WGBH Open Vault',
     :repository_url => 'http://localhost:3000',
     :record_prefix => 'http://openvault.wgbh.org/catalog',
     :admin_email => 'root@localhost'
  },
  :document => {
   :timestamp => 'timestamp'
  }
  }
end

