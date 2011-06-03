// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//
    //add ajaxy dialogs to certain links, using the ajaxyDialog widget.
    Blacklight.do_more_facets_behavior = function () {
      $( Blacklight.do_more_facets_behavior.selector ).ajaxyDialog({
          width: $(window).width() / 2,  
          chainAjaxySelector: "a.next_page, a.prev_page, a.sort_change",        
          dialogContainer: "#reusableModalDialog"
          //open: function() { $('#domsearch', this).domsearch($('ul.facet_extended_list', this)) }
      });
    };
    Blacklight.do_more_facets_behavior.selector = "a.more_facets_link";

    $(function() {
       comments_dialog = $('#document .blacklight-comments a').ajaxyDialog({
         modal: false,
         dialogContainer: '#annotations_modal_dialog'
       });
       $('.tools .cite a').ajaxyDialog( {
         modal: false
       });
       $('.new_tag,.new_annotation').ajaxyDialog({
         modal: false,
         dialogContainer: '#annotations_modal_dialog',
         load: function(event, dialog) {
           $('.record_annotation_metadata', dialog).append($('.media_fragment_template .media_fragment').clone());
         }
       });
      /* $('.user_util_links a').ajaxyDialog({
        width: $(window).width() / 2,
        chainAjaxySelector: ".folderTools a, .search_history a"
         });
        */
       $('a.comments').ajaxyDialog({
        width: $(window).width() / 2,
        modal: false,
         dialogContainer: '#annotations_modal_dialog'
         });

        try {
          start = /(comment-\d+)/.exec(location.hash).pop();
      

          scrollToComment = function(event, dialog) {
            comments_dialog.unbind('ajaxydialogafterdisplay');
            comment = $("." + start); 
             $('#annotations_modal_dialog').scrollTo(comment)
             comment.addClass('active');
          };
 comments_dialog.bind('ajaxydialogafterdisplay', scrollToComment)
          
          comments_dialog.first().ajaxyDialog("open");
        


         }
         catch(err) {
         }

        });



Blacklight.do_facet_expand_contract_behavior.selector = '#facets h3';

	    /* Behavior that makes facet limit headings in sidebar expand/contract
	       their contents. This is kind of fragile code targeted specifically
	       at how we currently render facet HTML, which is why I put it in a function
	       on Blacklight instead of in a jquery plugin. Perhaps in the future this
	       could/should be expanded to a general purpose jquery plugin -- or
	       we should just use one of the existing ones for expand/contract? */
     Blacklight.facet_expand_contract = function() {
       $(this).next("ul, div").each(function(){
           var f_content = $(this);
           $(f_content).prev('h3').addClass('twiddle twiddle-open');

           // attach the toggle behavior to the h3 tag
           $('h3', f_content.parent()).click(function(){
               // toggle the content
               $(this).toggleClass('twiddle-open');
               $(f_content).slideToggle();
           });
       });
   };

$(function() {
  $('#browse input').hide();
   $('#browse select').bind('change', function() {
     $(this).closest('form').submit();
   });
});


$(function() {
  if( $('body').height() < 1000) {
    $('html').css('backgroundPosition', '0 700px');
  }

  $('.facet_limit').not(':has(h3)').hide();
});

$(function() {

    var media_selector = 'video, audio';
    var player = null;

    $(media_selector).each(function() {
      options =  {
        'flashplayer': '/swfs/player.swf',
     //   provider: 'http',
     //   'http.startparam':'start', 
         skin: '/swfs/glow.zip',
         events: {
           onTime: function() {
              $(this).trigger('timeupdate'); // HTML5 event
           }
         },
        'plugins': {
           'gapro-2': {}
         }
    
      }

      if($(this).prev('img').length > 0 && $(this).is('audio')) {
        options['height'] = '28';
        options['controlbar'] = 'bottom';
      }
      jw = jwplayer($(this).attr('id')).setup(options);

      if(player == null) {
        player = jw;
      }
    });

         var start = 0;
         try {
          start = /t=(\d+)/.exec(location.hash).pop();
            player.play().seek(start);
         }
         catch(err) {
         }


    function timestamp_to_s(timestamp) {
      var s = 0;
              if(typeof timestamp != 'string' || timestamp.indexOf(':') == -1) { return timestamp; }
              var t = timestamp.split(":");

              s = parseFloat(t[2]);
              s += trimParseInt(t[1]) * 60;
              s += trimParseInt(t[0]) * 60*60;

              return s;
        }

   function trimParseInt(s) {
        if(s != undefined) {
            return s.replace(/^0+/,'');
        } else {
            return 0;
        }
  }

   if($('.datastream-video,.datastream-audio').length > 0 && $('.datastream-transcript').length > 0) {
     //select all timecode-enabled elements
     $('*[data-timecode_begin]').attr('data-timecode', true);
     $('*[data-timecode_end]').attr('data-timecode', true);
     smil_elements = $('*[data-timecode]');

     smil_elements.each(function(index) {
       //fill in missing timecode as best as possible
       if(($(this).data('timecode_begin')) == 'undefined') {
         var pred = smil_elements.slice(0, index).has('*[data-timecode]');
         $(this).data('timecode_begin', Math.max(timestamp_to_s(pred.grep(function(e) { return $(e).is('*[data-timecode_end]') }).first().data('timecode_end')), timestamp_to_s(pred.grep(function(e) { return $(e).is('*[data-timecode_begin]') }).first().data('timecode_begin'))));
       }

       if(($(this).data('timecode_end')) == 'undefined') {
         var pred = smil_elements.slice(0, index).has('*[data-timecode]');
         $(this).data('timecode_end', Math.min(timestamp_to_s(pred.grep(function(e) { return $(e).is('*[data-timecode_begin]') }).first().data('timecode_begin')), timestamp_to_s(pred.grep(function(e) { return $(e).is('*[data-timecode_end]') }).first().data('timecode_end'))));
       }
     });

     //convert hh:mm:ss.ff to seconds
     smil_elements.each(function() {
       var begin = timestamp_to_s($(this).data('timecode_begin'));
       var end = timestamp_to_s($(this).data('timecode_end'));
        $(this).data('begin_seconds', begin);
        $(this).data('end_seconds', end);
     });

     //sync the media with the transcript
     $(player).sync(smil_elements, { 'time': function() { return this.getPosition() }});
     smil_elements.bind('sync-on', function() { $(this).addClass('current'); });
     smil_elements.bind('sync-off', function() { 
       $('.last').removeClass('last');
       $(this).removeClass('current').addClass('last'); 
     });

     //sync the transcript with the media
     smil_elements.each(function() {
       $('<a class="sync">[sync]</a>').prependTo($(this)).bind('click', function() { player.seek($(this).parent().data('begin_seconds')); }) ;
     });
     if(smil_elements.length > 0) {
       $('<a class="sync">[sync]</a>').prependTo($('.datastream-actions')).bind('click', function() {
         if($('.current').length > 0) {
     $('.secondary-datastream').scrollTo($('.current'));
         } else {
     $('.secondary-datastream').scrollTo($('.last'));

         }
    return false;
  });
     }
   }
    });

(function($) {
  $.fn.sync = function(target, options) {
    media = this;
    var settings = {
      'begin' : 'begin_seconds',
      'end' : 'end_seconds',
      'on' : function() { $(this).trigger('sync-on'); },
      'off' : function() { $(this).trigger('sync-off'); },
      'time' : function() { return this.currentTime },
      'poll' : false,
      'pollingInterval' : 1000,
      'event': 'timeupdate'
    }

    $.extend( settings, options );

    if(settings['poll']) {
      setInterval(function() { $(media).trigger('timeupdate'); }, settings['pollInterval']);
    } 

    this.bind(settings['event'], function() {
      t = jQuery.proxy(settings['time'], this)();
      target.each(function() {
       if($(this).data(settings['begin']) <= t && t <= $(this).data(settings['end'])) {
         if($(this).data('sync') != true) {
           $(this).data('sync', true);
           jQuery.proxy(settings['on'], this)();
         }
       } else {
         if($(this).data('sync') == true) {
           $(this).data('sync', false);
           jQuery.proxy(settings['off'], this)();
         }
       }
      });
    });

  }

}(jQuery));


$(function() {
  var last_search = null;
  var i = 0;
  var max = 0;

  //$('.datastream-transcript').sausage({page: 'h3', content: function(i, $page) { return ''}, onClick: function(e, o) { $('.datastream-transcript').scrollTo($('h3', '.datastream-transcript').eq(o.i)); }});


   $('.datastream-action-search').bind('submit', function() {
     current_search = $('input:text', this).val();

     if(current_search != last_search) {
       $('.secondary-datastream').unhighlight().highlight(current_search);

       $('.tei-metadata .highlight').each(function() {
          $('.secondary-datastream .tei-name-' + $(this).parent().attr('id')).addClass('highlight');
          $(this).removeClass('highlight');
       });

       max = $('.secondary-datastream .highlight').length
     if(max == 0) {
       alert('No results found');
       return false;
     }

       last_search = current_search;
       i = 0;
     }

     $('.secondary-datastream').scrollTo($('.secondary-datastream .highlight').eq(i));
     i++;
     if(i > max) {
       i = 0;
     }
     return false;
   });
});
