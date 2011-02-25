// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//
    //add ajaxy dialogs to certain links, using the ajaxyDialog widget.
    Blacklight.do_more_facets_behavior = function () {
      $( Blacklight.do_more_facets_behavior.selector ).ajaxyDialog({
          width: $(window).width() / 2,  
          chainAjaxySelector: "a.next_page, a.prev_page, a.sort_change",        
          open: function() { $('#domsearch', this).domsearch($('ul.facet_extended_list', this)) }
      });
    };
    Blacklight.do_more_facets_behavior.selector = "a.more_facets_link";

    $(function() {
       $('.user_util_links a').ajaxyDialog({
        width: $(window).width() / 2,
        chainAjaxySelector: ".folderTools a, .search_history a"
         });
        });

